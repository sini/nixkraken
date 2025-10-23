[hm]: https://nix-community.github.io/home-manager
[doc-sync-nixpkgs-hm]: ./writing.md#nixkrakennix
[nix-manual-lookup-path]: https://nix.dev/manual/nix/stable/language/constructs/lookup-path
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes

# Running Tests

To run tests locally, use the following commands:

```sh
# Run the entire test suite
$ nix build '.#tests.all'
```

```sh
# List all available tests
$ nix run '.#tests.show'
```

```sh
# Run a single test
$ nix build '.#tests.<test-name>'
```

```sh
# Run a test interactively (useful for debugging or crafting new tests)
# This starts an interactive Python REPL with test framework symbols exposed
$ nix run '.#tests.<test-name>.driverInteractive'
```

## Run without Flakes

While running tests without [Flakes][nixos-wiki-flakes] is possible, we do not recommend it as it is not as user-friendly as with Flakes.

If you still want to avoid using Flakes, here is how to do it:

```sh
# Run from the root repository directory
$ nix-build ./tests \
  -I nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz \
  -A '<all|show|test-name>'
```

The `nixpkgs` [lookup path][nix-manual-lookup-path] **must be in sync** with the one expected by [Home Manager][hm] (see [here][doc-sync-nixpkgs-hm] for further details).

Additionally, please note that `show` and interactive tests will need to be executed manually after building:

```sh
# List available tests
$ ./result/bin/show-tests
```

```sh
# Run interactive test
$ ./result/bin/nixos-test-driver
```

## Test Results

After a test completes and if screenshots were taken as part of it, they will be available in the `result` directory.

- for single runs: `result/<screenshot-name>.png`
- for the full suite: `result/share/<test-name>/<screenshot-name>.png`
