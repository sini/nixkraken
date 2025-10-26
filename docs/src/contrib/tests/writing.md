[doc-opt-enabled]: ../../reference/root.md#enabled
[doc-running-tests-gk-version]: ./running.md#set-gitkraken-version
[flakes-outputs]: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
[garnix]: https://garnix.io
[gitkraken]: https://www.gitkraken.com/git-client
[hm-nixos-sync]: https://nix-community.github.io/home-manager/index.xhtml#sec-upgrade-release-overview
[hm]: https://nix-community.github.io/home-manager/index.xhtml
[loc-example]: #minimal-example
[loc-rules]: #rules
[loc-shared-conf]: #shared-configuration
[loc-testpy]: #about-testpy
[nix-manual-attrs]: https://nix.dev/manual/nix/stable/language/syntax#attrs-literal
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nixos-manual-machine-objects]: https://nixos.org/manual/nixos/stable/#ssec-machine-objects
[nixos-manual-modules]: https://nixos.org/manual/nixos/stable/#sec-writing-modules
[nixos-manual-test-option]: https://nixos.org/manual/nixos/stable/#test-opt-test
[nixos-manual-tests-nodes]: https://nixos.org/manual/nixos/stable/#test-opt-nodes
[nixos-manual-tests-ocr]: https://nixos.org/manual/nixos/stable/#test-opt-enableOCR
[nixos-manual-tests-opts]: https://nixos.org/manual/nixos/stable/#sec-test-options-reference
[nixos-manual-tests]: https://nixos.org/manual/nixos/stable/#sec-nixos-tests
[nixos-manual-testscript-option]: https://nixos.org/manual/nixos/stable/#test-opt-testScript
[nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable/#overview-of-nixpkgs
[python-unittest-testcases]: https://docs.python.org/3/library/unittest.html#test-cases
[python]: https://www.python.org
[repo-common-display]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common/display.nix
[repo-common-nixkraken]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common/nixkraken.nix
[repo-datetime-test]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/datetime
[repo-flake]: https://github.com/nicolas-goudry/nixkraken/blob/main/flake.nix
[repo-mktest]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/default.nix
[repo-tests-common]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests/_common
[repo-tests-root]: https://github.com/nicolas-goudry/nixkraken/blob/main/tests
[wikipedia-kebab-case]: https://en.wikipedia.org/wiki/Letter_case#Kebab_case

# Writing Tests

::: warning

**Contributors willing to work on tests should be familiar with [NixOS test framework][nixos-manual-tests].**

:::

## Overview

All tests live inside the [`tests` directory][repo-tests-root] and are automatically imported into the test suite using a [custom `mkTest` function][repo-mktest] which allows various ways to define the tests:

1. As a simple [attribute set][nix-manual-attrs], which will be used as the [test machine NixOS module][nixos-manual-tests-nodes]

   ```nix
   {
     home-manager.users.root.programs.nixkraken.enable = true;
   }
   ```

2. As a list of attribute sets, which will be used as the test machines NixOS modules

   ```nix
   [
     {
       home-manager.users.root.programs.nixkraken.enable = true;
     }
     # ...other machines
   ]
   ```

3. As an attribute set with `machine` and `extraOptions` attributes, respectively used as the test machine(s) NixOS module(s) and additional [test options][nixos-manual-tests-opts]

   ```nix
   {
     machine = {
       home-manager.users.root.programs.nixkraken.enable = true;
     };

     # Or multiple machines
     # machine = [
     #   {
     #     home-manager.users.root.programs.nixkraken.enable = true;
     #   }
     # ]

     extraOptions = {
       skipTypeCheck = true;
       extraPythonPackages = p: with p; [ numpy ]; };
   }
   ```

4. As a [function][nix-manual-functions] called with the `pkgs` attribute set containing [nixpkgs][nixpkgs-manual], which can return either of the previous attribute sets

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

::: info

- all tests use one or more machines
- all tests have [OCR capabilities][nixos-manual-tests-ocr] enabled (which cannot be disabled)
- all [test machines share default configuration][loc-shared-conf] (which is not overwritable)
- using the [`test` option][nixos-manual-test-option] is disallowed in favor of `testScript` (see [test rules about files][loc-rules] below)

:::

## Flake Exposure

Tests are exposed as `legacyPackages` [Flake outputs][flakes-outputs] rather than `packages` for the following reasons:

- they are still runnable/buildable with `nix run` and `nix build`
- they are not validated by `nix flake check` (`.#tests` is a namespace, not a derivation)
- they are not built by [Garnix][garnix] (avoids CI overhead and inevitable build failures due to previous point)

## Rules

**Each test must follow the rules described in this section.**

### Naming Convention

Use a clear, concise and descriptive name in [kebab case][wikipedia-kebab-case]

- This is correct: `accept-eula`
- This is incorrect: `acceptEula`, `accept_eula`, …

### Directory Structure

Each test has its own subdirectory, matching its name.

Example:

```txt
tests
└── accept-eula
    ├── default.nix
    └── test.py
```

### Required Files

At a minimum, each test should define two files:

- `default.nix`: defines the [machine module][nixos-manual-tests-nodes] and, optionally, extra [test options][nixos-manual-tests-opts] beyond default ones
- `test.py`: contains the [Python][python] test logic (automatically loaded in [`testScript` test option][nixos-manual-testscript-option] - read the [dedicated section][loc-testpy] for further details)

Additional files relevant to the test can be added in the test directory. Look at the [datetime test][repo-datetime-test] for a real-world example.

### Taking Screenshots

When graphical output is being validated, screenshots must be produced using the expression below:

```py
# Take a screenshot of the machine
machine1.screenshot('snapshot')
```

The test framework will generate screenshots in PNG format in the derivation output.

### Use Subtests

Even when a test is testing a single thing, use `subtest` as shown below:

```py
with subtest("Test name"):
    # Actual test code
```

See [minimal example][loc-example] for details.

## About `test.py`

As previously noted, all tests must define a `test.py` file containing the [Python][python] test logic. Find below some useful details about it:

- test machines are named `machine{id}`, where `{id}` is the machine index starting at `1`
- each test machine is exposed as a [Machine object][nixos-manual-machine-objects] identified by its name (i.e., `machine1`, `machine2`, …)
- the Machine object provides methods to interact with the matching test machine:
  - execute shell commands
  - get a textual representation of the machine screen
  - take screenshots of the machine display
  - send arbitrary typing sequences
  - simulate pressing keys
  - wait for various operations like X server start, window to appear, text to be displayed, …
  - […and much more][nixos-manual-machine-objects]
- the `t` object exposes all assertions from [Python's `unittest.TestCase`][python-unittest-testcases]

### GitKraken Quirks

- Because [GitKraken][gitkraken] is a graphical application, most tests require starting an X server
- GitKraken will fail to run under `root` user unless `--no-sandbox` flag is used
- waiting for GitKraken window succeeds before the window is actually drawn on screen, requiring a sleep workaround

### Minimal Example

```py
# pyright: reportUndefinedVariable=false

# Wait for graphical server
machine1.wait_for_x()

with subtest("Test name"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine1.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 15 seconds sleep workaround (which is required)
    machine1.wait_for_window("GitKraken Desktop")
    machine1.sleep(15)

    # Dummy test example, actual tests should go here
    machine1.succeed("true")

    # Take a screenshot of GitKraken
    machine1.screenshot("snapshot")

# Exit GitKraken
machine1.succeed("pkill -f gitkraken")
```

## Shared Configuration

The [`_common` directory][repo-tests-common] holds [NixOS modules][nixos-manual-modules] shared across all tests to avoid repetition and ensure a consistent environment.

```txt
tests/_common
├── base-config.nix
├── default.nix
├── display.nix
└── nixkraken.nix
```

Additionally, all tests have NixKraken force-enabled ([with `enabled` option][doc-opt-enabled]) and are using the latest GitKraken version available, unless [stated otherwise][doc-running-tests-gk-version].

### `default.nix`

Imports the minimum required configuration to be able to use NixKraken in tests.

It automatically imports `display.nix` and `nixkraken.nix`, so that tests only need to import `_common` for being able to test NixKraken.

::: info

The `_common` directory is imported by default in all tests.

:::

### `display.nix`

Defines NixOS configuration options to enable display in tests.

It configures X11 and a display/window manager, required by most tests since GitKraken is a graphical application.

It should remain mostly stable, updated only for compatibility with future NixOS versions.

### `nixkraken.nix`

Enables both [Home Manager][hm] and NixKraken in tests.

This is (obviously?) required to be able to test NixKraken.

::: warning

Whenever [nixpkgs][nixpkgs-manual] gets updated in [`flake.nix`][repo-flake], the Home Manager version defined in this file must be updated accordingly.

This is due to the way Home Manager works: both [Home Manager and nixpkgs versions must be in sync][hm-nixos-sync].

:::

### `base-config.nix`

Defines a basic working GitKraken configuration which will give a usable UI on app launch.

This configuration is optional. It is useful for tests that needs a working app to perform tests.

A good example of this is the [datetime test][repo-datetime-test], which needs to open the repository view to perform its tests.
