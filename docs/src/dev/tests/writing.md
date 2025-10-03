# Writing tests

> [!IMPORTANT]
>
> **Contributors willing to work on tests should be familiar with [NixOS test framework](https://nixos.org/manual/nixos/stable/#sec-nixos-tests).**

## Overview

All tests live inside the [tests](https://github.com/nicolas-goudry/nixkraken/blob/main/tests) directory and are automatically imported into the test suite using a [custom `mkTest` function](https://github.com/nicolas-goudry/nixkraken/blob/main/tests/default.nix) which allows various ways to define the tests:

1. As a simple attribute set, which will be used as the [test machine NixOS module](https://nixos.org/manual/nixos/stable/#test-opt-nodes)
   ```nix
   {
     home-manager.users.root.programs.nixkraken.enable = true;
   }
   ```
2. As an attribute set with `machine` and `extraOptions` attributes, respectively used as the test machine NixOS module and additional [test options](https://nixos.org/manual/nixos/stable/#sec-test-options-reference)

   ```nix
   {
     machine = {
       home-manager.users.root.programs.nixkraken.enable = true;
     };

     extraOptions = {
       skipTypeCheck = true;
     };
   }
   ```

3. As a single argument function called with the `pkgs` attribute set containing nixpkgs, which can return either of the previous attribute sets

   ```nix
   pkgs:

   {
     environment.systemPackages = with pkgs; [
       jq
     ];
   }
   ```

   ```nix
   # Variant
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

## Flake exposure

Tests are exposed as `legacyPackages` outputs rather than `packages` for the following reasons:

- they are still runnable/buildable with `nix run` and `nix build`
- they are not validated by `nix flake check` (`.#tests` is a namespace, not a derivation)
- they are not built by [Garnix](https://garnix.io) (avoids CI overhead and inevitable build failures)

## Rules

**Each test must follow the rules described in this section.**

### Naming convention

Use a clear, concise and descriptive name in [kebab case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case)

- This is correct: `accept-eula`
- This is incorrect: `acceptEula`, `accept_eula`, …

### Directory structure

Each test has its own subdirectory, matching its name.

Example:

```plain
tests
└── accept-eula
    ├── default.nix
    └── test.py
```

### Required files

At a minimum, each test should define two files:

- `default.nix`: defines the machine module and, optionally, extra test options beyond default ones
- `test.py`: contains the Python test logic (automatically loaded in [`testScript` test option](https://nixos.org/manual/nixos/stable/#test-opt-testScript) - read the [dedicated section](#about-testpy) for further details)

Additional files relevant to the test can be added in the test directory. Look at the [`datetime`](https://github.com/nicolas-goudry/nixkraken/blob/main/tests/datetime) test for a real-world example.

### Taking screenshots

When graphical output is being validated, screenshots must be produced using the expression below:

```py
# Take a screenshot of the machine
machine.screenshot('snapshot')
```

The test framework will generate screenshots in PNG format in the derivation output.

### Use subtests

Even when a test is testing a single thing, use `subtest` as shown below:

```py
with subtest("Test name"):
    # Actual test code
```

See [minimal example](#minimal-example) for details.

## About `test.py`

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

### GitKraken quirks

- GitKraken being a graphical application, most tests require starting an X server
- GitKraken will fail to run under `root` user unless `--no-sandbox` flag is used
- waiting for GitKraken window succeeds before the window is actually drawn on screen, requiring a sleep workaround

### Minimal example

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
