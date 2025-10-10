[flakes-outputs]: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
[garnix]: https://garnix.io
[github-flake]: https://github.com/nicolas-goudry/nixkraken/blob/main/flake.nix
[github-src-datetime-test]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/datetime
[github-src-mktest]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/default.nix
[github-src-tests-common-display]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common/display.nix
[github-src-tests-common-nixkraken]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common/nixkraken.nix
[github-src-tests-common]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common
[github-src-tests]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests
[gitkraken]: https://www.gitkraken.com/git-client
[home-manager-nixos-sync]: https://nix-community.github.io/home-manager/index.xhtml#sec-upgrade-release-overview
[loc-minimal-example]: #minimal-example
[loc-rules]: #test-rules
[loc-shared-configuration]: #shared-configuration
[loc-testpy]: #about-testpy
[nix-manual-attrs]: https://nix.dev/manual/nix/stable/language/syntax#attrs-literal
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nixos-manual-modules]: https://nixos.org/manual/nixos/stable/#sec-writing-modules
[nixos-manual-tests-machine-objects]: https://nixos.org/manual/nixos/stable/#ssec-machine-objects
[nixos-manual-tests-nodes]: https://nixos.org/manual/nixos/stable/#test-opt-nodes
[nixos-manual-tests-ocr-option]: https://nixos.org/manual/nixos/stable/#test-opt-enableOCR
[nixos-manual-tests-options]: https://nixos.org/manual/nixos/stable/#sec-test-options-reference
[nixos-manual-tests-test-option]: https://nixos.org/manual/nixos/stable/#test-opt-test
[nixos-manual-tests-testscript-option]: https://nixos.org/manual/nixos/stable/#test-opt-testScript
[nixos-manual-tests]: https://nixos.org/manual/nixos/stable/#sec-nixos-tests
[nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable/#overview-of-nixpkgs
[python-unittest-testcases]: https://docs.python.org/3/library/unittest.html#test-cases
[python]: https://www.python.org
[wikipedia-kebab-case]: https://en.wikipedia.org/wiki/Letter_case#Kebab_case

# Writing tests

> [!IMPORTANT]
>
> **Contributors willing to work on tests should be familiar with [NixOS test framework][nixos-manual-tests].**

## Overview

All tests live inside the [tests][github-src-tests] directory and are automatically imported into the test suite using a [custom `mkTest` function][github-src-mktest] which allows various ways to define the tests:

1. As a simple [attribute set][nix-manual-attrs], which will be used as the [test machine NixOS module][nixos-manual-tests-nodes]

   ```nix
   {
     home-manager.users.root.programs.nixkraken.enable = true;
   }
   ```

2. As an attribute set with `machine` and `extraOptions` attributes, respectively used as the test machine NixOS module and additional [test options][nixos-manual-tests-options]

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

3. As a [function][nix-manual-functions] called with the `pkgs` attribute set containing [nixpkgs][nixpkgs-manual], which can return either of the previous attribute sets

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
> - all tests have [OCR capabilities][nixos-manual-tests-ocr-option] enabled (which cannot be disabled)
> - all [test machines share default configuration][loc-shared-configuration] (which is not overwritable)
> - using the [`test` option][nixos-manual-tests-test-option] is disallowed in favor of `testScript` (see [test rules about files][loc-rules] below)

## Flake exposure

Tests are exposed as `legacyPackages` [Flake outputs][flakes-outputs] rather than `packages` for the following reasons:

- they are still runnable/buildable with `nix run` and `nix build`
- they are not validated by `nix flake check` (`.#tests` is a namespace, not a derivation)
- they are not built by [Garnix][garnix] (avoids CI overhead and inevitable build failures)

## Rules

**Each test must follow the rules described in this section.**

### Naming convention

Use a clear, concise and descriptive name in [kebab case][wikipedia-kebab-case]

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

- `default.nix`: defines the [machine module][nixos-manual-tests-nodes] and, optionally, extra [test options][nixos-manual-tests-options] beyond default ones
- `test.py`: contains the [Python][python] test logic (automatically loaded in [`testScript` test option][nixos-manual-tests-testscript-option] - read the [dedicated section][loc-testpy] for further details)

Additional files relevant to the test can be added in the test directory. Look at the [`datetime` test][github-src-datetime-test] for a real-world example.

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

See [minimal example][loc-minimal-example] for details.

## About `test.py`

As previously noted, all tests must define a `test.py` file containing the [Python][python] test logic. Find below some useful details about it:

- the `machine` object provides methods to interact with the test machine:
  - execute shell commands
  - get a textual representation of the machine screen
  - take screenshots of the machine display
  - send arbitrary typing sequences
  - simulate pressing keys
  - wait for various operations like X server start, window to appear, text to be displayed, …
  - […and much more][nixos-manual-tests-machine-objects]
- the `t` object exposes all assertions from [Python's `unittest.TestCase`][python-unittest-testcases]

### GitKraken quirks

- Because [GitKraken][gitkraken] is a graphical application, most tests require starting an X server
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

The [`_common` directory][github-src-tests-common] holds [NixOS modules][nixos-manual-modules] shared across all tests to avoid repetition and ensure a consistent environment.

```plain
tests/_common
├── default.nix    # imports display.nix and nixkraken.nix
├── display.nix    # setup graphical capabilities (X11 server, IceWM, LightDM, root autologin)
└── nixkraken.nix  # setup Home Manager and NixKraken modules
```

> [!IMPORTANT]
>
> - [`display.nix`][github-src-tests-common-display] should remain mostly stable, updated only for compatibility with future NixOS versions
> - [due to the way Home Manager works][home-manager-nixos-sync], [`nixkraken.nix`][github-src-tests-common-nixkraken] must be updated to pull in a version of Home Manager matching the [nixpkgs][nixpkgs-manual] version defined in [`flake.nix`][github-flake]
