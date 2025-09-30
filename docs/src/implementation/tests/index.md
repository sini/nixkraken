# Tests

NixKraken includes an automated test suite to ensure that contributors and users alike can count on a smooth, reproducible experience.

The tests rely on the [NixOS test framework](https://nixos.org/manual/nixos/stable/#sec-nixos-tests), which spins up lightweight virtual machines (VMs) where different NixKraken configurations can be validated. This approach lets us test graphical behavior, NixOS module integration, and system-level interactions, all inside a controlled environment.

> [!WARNING]
>
> Although we aim to test as many configuration outcomes as possible, these automated tests will never be able to cover every possible configuration.
>
> Specifically, we are not currently able to test paid features since the login process is interactive. Hence, we cannot test multi-profiles setups beyond Nix validation.

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
> Although it's possible to run tests without Flakes, we strongly recommend them for ease of use.
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
> Additionally, _runnable_ commands (ie. `nix run`) will need to be called manually once built:
>
> ```bash
> # List available tests
> ./result/bin/show-tests
>
> # Run interactive test
> ./result/bin/nixos-test-driver
> ```

### Test results and artifacts

After a test completes, its output (if any) is available in the `result` directory.

Tests that produce a screenshot will save it as `snapshot.png`:

- for single runs: `result/snapshot.png`
- for the full suite: `result/share/<test-name>/snapshot.png`

## Flake exposure

As one may notice, tests are exposed as Flake outputs using the `legacyPackages` output rather than the usual `packages`.

This is done for several reasons:

- they are still runnable/buildable with `nix run` and `nix build`
- they are not validated by `nix flake check` (`.#tests` is a namespace, not a derivation)
- they are not built by Garnix (avoids CI overhead and inevitable build failures)

## Writing tests

All tests live inside the [tests](https://github.com/nicolas-goudry/nixkraken/blob/main/tests) directory. Each test must follow the rules described below:

**Naming convention**

Use a clear, concise and descriptive name in [kebab case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case)

- This is correct: `accept-eula`
- This is incorrect: `acceptEula`, `accept_eula`, …

**Directory structure**

Each test has its own subdirectory, matching its name.

Example:

```plain
tests
└── accept-eula
    ├── default.nix
    └── test.py
```

**Files**

At a minimum, each test should define two files:

- `default.nix`: defines the NixOS test (using `pkgs.testers.runNixOSTest`)
- `test.py`: contains the Python test logic

Additional files relevant to the test can be added in the test directory. An example of that is the [`datetime`](https://github.com/nicolas-goudry/nixkraken/blob/main/tests/datetime) test.

**Screenshots**

When graphical output is being validated, we recommend to produce a screenshot using the instruction below:

```py
# Take a screenshot of the machine
machine.screenshot('snapshot')
```

Only one screenshot is allowed per test and it must be named `snapshot`. The test framework will generate them in PNG format.

**Other rules**

- all tests must import configuration from `_common` (see the [dedicated section](#shared-configuration))
- use [`enableOCR`](https://nixos.org/manual/nixos/stable/#test-opt-enableOCR) only when text recognition is required

### Example `test.py`

Since GitKraken is a graphical application, most tests require starting an X server.

A minimal test looks like this:

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

## Shared configuration

The `_common` directory holds NixOS configuration shared across all tests, so we avoid repetition and have a stable GUI for tests.

```plain
tests/_common
├── default.nix    # imports display.nix and nixkraken.nix
├── display.nix    # setup graphical capabilities (X11 server, IceWM, LightDM, autologin)
└── nixkraken.nix  # setup Home Manager and NixKraken modules
```

Note for contributors:

- `display.nix` should remain mostly stable, updated only for compatibility with future NixOS versions
- [due to the way Home Manager works](https://nix-community.github.io/home-manager/index.xhtml#sec-upgrade-release-overview), `nixkraken.nix` must be updated to pull in a version of Home Manager matching the `nixpkgs` version defined in `flake.nix`
