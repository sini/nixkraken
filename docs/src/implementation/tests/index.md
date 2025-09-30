# Tests

NixKraken includes an automated test suite to ensure that contributors and users alike can count on a smooth, reproducible experience.

The tests rely on the [NixOS test framework](https://nixos.org/manual/nixos/stable/#sec-nixos-tests), which spins up lightweight virtual machines (VMs) where different NixKraken configurations can be validated. This approach lets us test graphical behavior, NixOS module integration, and system-level interactions, all inside a controlled environment.

> [!WARNING]
>
> Although we aim to test as many configuration outcomes as possible, these automated tests will never be able to cover every possible configuration.
>
> Specifically, we are not currently able to test paid features since the login process is interactive. Hence, we cannot test multi-profile setups beyond Nix validation.

## Running tests

To run tests locally, use the following commands:

```bash
# Run the entire test suite
nix build '.#tests.all'

# List all available tests
nix run '.#tests.show'

# Run a single test
nix build '.#tests.<test-name>'

# Run a test interactively (useful for debugging or crafting new tests)
# This starts an interactive Python REPL with test framework symbols exposed
# Read more about this in the official test framework documentation linked above
nix run '.#tests.<test-name>.driverInteractive'
```

> [!NOTE]
>
> While running tests without Flakes is possible, we don't recommend it as it's not as user-friendly as with Flakes.
>
> If you still want to avoid using Flakes, here is how to do it:
>
> ```bash
> # Run from the root repository directory
> nix-build ./tests \
>   -I nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz \
>   -A '<all|show|test-name>'
> ```
>
> The `nixpkgs` input **must be in sync** with the one expected by Home Manager (see [shared configuration](#shared-configuration) section).
>
> Additionally, commands that use `nix run` (when used with Flakes) will need to be executed manually after building:
>
> ```bash
> # List available tests
> ./result/bin/show-tests
>
> # Run interactive test
> ./result/bin/nixos-test-driver
> ```

### Test results and artifacts

After a test completes and if screenshots were taken as part of it, they will be available in the `result` directory.

- for single runs: `result/<screenshot-name>.png`
- for the full suite: `result/share/<test-name>/<screenshot-name>.png`

### Flake exposure

Tests are exposed as `legacyPackages` outputs rather than `packages` for the following reasons:

- they are still runnable/buildable with `nix run` and `nix build`
- they are not validated by `nix flake check` (`.#tests` is a namespace, not a derivation)
- they are not built by [Garnix](https://garnix.io) (avoids CI overhead and inevitable build failures)

## Writing tests

> [!IMPORTANT]
>
> **Contributors willing to work on tests should be familiar with [NixOS test framework](https://nixos.org/manual/nixos/stable/#sec-nixos-tests).**

All tests live inside the [tests](https://github.com/nicolas-goudry/nixkraken/blob/main/tests) directory and are automatically imported into the test suite using a [custom `mkTest` function](https://github.com/nicolas-goudry/nixkraken/blob/main/tests/default.nix) which allows various ways to define the tests:

1. As a simple attribute set, which will be used as the [test machine NixOS module](https://nixos.org/manual/nixos/stable/#test-opt-nodes)
2. As an attribute set with `machine` and `extraOptions` attributes, respectively used as the test machine NixOS module and additional [test options](https://nixos.org/manual/nixos/stable/#sec-test-options-reference)
3. As a single argument function called with the `pkgs` attribute set containing nixpkgs, which can return either of the previous attribute sets

```nix
# Simple NixOS module
{
  home-manager.users.root.programs.nixkraken.enable = true;
}

# Attribute set allowing to add extra options to the test definition
{
  machine = {
    home-manager.users.root.programs.nixkraken.enable = true;
  };

  extraOptions = {
    skipTypeCheck = true;
  };
}

# Function to use packages in the test machine (can return either simple module or machine + extraOptions)
{ jq, ... }:

{
  environment.systemPackages = [
    jq
  ];
}
```

> [!NOTE]
>
> - all tests use a single machine named `machine`
> - all tests have [OCR capabilities](https://nixos.org/manual/nixos/stable/#test-opt-enableOCR) enabled (which cannot be disabled)
> - all [test machines share default configuration](#shared-configuration) (which is not overwritable)
> - using the [`test` option](https://nixos.org/manual/nixos/stable/#test-opt-test) is disallowed in favor of `testScript` (see [test rules about files](#test-rules) below)

### Test rules

**Each test must follow the rules described in this section.**

#### Naming convention

Use a clear, concise and descriptive name in [kebab case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case)

- This is correct: `accept-eula`
- This is incorrect: `acceptEula`, `accept_eula`, …

#### Directory structure

Each test has its own subdirectory, matching its name.

Example:

```plain
tests
└── accept-eula
    ├── default.nix
    └── test.py
```

#### Required files

At a minimum, each test should define two files:

- `default.nix`: defines the machine module and, optionally, extra test options beyond default ones
- `test.py`: contains the Python test logic (automatically loaded in [`testScript` test option](https://nixos.org/manual/nixos/stable/#test-opt-testScript) - read the [dedicated section](#about-testpy) for further details)

Additional files relevant to the test can be added in the test directory. Look at the [`datetime`](https://github.com/nicolas-goudry/nixkraken/blob/main/tests/datetime) test for a real-world example.

#### Taking screenshots

When graphical output is being validated, screenshots must be produced using the expression below:

```py
# Take a screenshot of the machine
machine.screenshot('snapshot')
```

The test framework will generate screenshots in PNG format in the derivation output.

#### Use subtests

Even when a test is testing a single thing, use `subtest` as shown below:

```py
with subtest("Test name"):
    # Actual test code
```

See [minimal example](#minimal-example) for details.

### About `test.py`

As previously noted, all tests must define a `test.py` file containing the Python test logic. Find below some useful details about it:

- the `machine` object provides methods to interact with the test machine:
  - execute shell commands
  - get a textual representation of the machine screen
  - take screenshots of the machine display
  - send arbitrary typing sequences
  - simulate pressing keys
  - wait for various operations like X server start, window to appear, text to be displayed, …
  - […and much more](https://nixos.org/manual/nixos/stable/#ssec-machine-objects)
- the `t` object exposes all assertions from [Python's `unittest.TestCase`](https://docs.python.org/3/library/unittest.html#test-cases)

#### GitKraken quirks

- GitKraken being a graphical application, most tests require starting an X server
- GitKraken will fail to run under `root` user unless `--no-sandbox` flag is used
- waiting for GitKraken window succeeds before the window is actually drawn on screen, requiring a sleep workaround

#### Minimal example

```py
# pyright: reportUndefinedVariable=false

# Wait for graphical server
machine.wait_for_x()

with subtest("Test name"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 15 seconds sleep workaround (which is required)
    machine.wait_for_window("GitKraken Desktop")
    machine.sleep(15)

    # Dummy test example, actual tests should go here
    machine.succeed("true")

    # Take a screenshot of GitKraken
    machine.screenshot("snapshot")

# Exit GitKraken
machine.succeed("pkill -f gitkraken")
```

### Shared configuration

The `_common` directory holds NixOS configuration shared across all tests to avoid repetition and ensure a consistent GUI environment.

```plain
tests/_common
├── default.nix    # imports display.nix and nixkraken.nix
├── display.nix    # setup graphical capabilities (X11 server, IceWM, LightDM, root autologin)
└── nixkraken.nix  # setup Home Manager and NixKraken modules
```

> [!IMPORTANT]
>
> - `display.nix` should remain mostly stable, updated only for compatibility with future NixOS versions
> - [due to the way Home Manager works](https://nix-community.github.io/home-manager/index.xhtml#sec-upgrade-release-overview), `nixkraken.nix` must be updated to pull in a version of Home Manager matching the `nixpkgs` version defined in `flake.nix`
