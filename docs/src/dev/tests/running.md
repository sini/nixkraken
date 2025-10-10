# Running tests

To run tests locally, use the following commands:

```bash
# Run the entire test suite
nix build '.#tests.all'
```

```bash
# List all available tests
nix run '.#tests.show'
```

```bash
# Run a single test
nix build '.#tests.<test-name>'
```

```bash
# Run a test interactively (useful for debugging or crafting new tests)
# This starts an interactive Python REPL with test framework symbols exposed
# Read more about this in the official test framework documentation linked above
nix run '.#tests.<test-name>.driverInteractive'
```

> [!NOTE]
>
> While running tests without Flakes is possible, we do not recommend it as it is not as user-friendly as with Flakes.
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
> ```
>
> ```bash
> # Run interactive test
> ./result/bin/nixos-test-driver
> ```

## Test results

After a test completes and if screenshots were taken as part of it, they will be available in the `result` directory.

- for single runs: `result/<screenshot-name>.png`
- for the full suite: `result/share/<test-name>/<screenshot-name>.png`
