[doc-configure]: ./configure.md
[doc-encrypt-decrypt]: ./encrypt-decrypt.md
[doc-login]: ./login.md
[doc-theme]: ./theme.md
[flakes-outputs]: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
[gitkraken]: https://www.gitkraken.com/git-client
[nix-manual]: https://nix.dev/manual/nix/stable
[nixdev-shell]: https://nix.dev/tutorials/first-steps/declarative-shell#declarative-reproducible-envs
[nixpkgs-manual-pkgsdirrec]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.filesystem.packagesFromDirectoryRecursive
[nixpkgs-manual-writeshellapp]: https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication
[nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable/#preface

# Helper Packages

NixKraken uses several packages to perform actions related to [GitKraken][gitkraken] configuration handling. Because GitKraken's configuration files also store mutable application state, they cannot be written directly by [Nix][nix-manual]. Instead, these packages are used to safely read, modify, and write to the JSON configuration files without destroying the state.

Packages are written in Python and are dynamically exported using the [`packagesFromDirectoryRecursive` function][nixpkgs-manual-pkgsdirrec]. Adding a directory under `pkgs` with a `package.nix` will automatically make a package (named after the directory) available for use.

::: tip

When you enter a [Nix development shell][nixdev-shell], the packages are available as their `gk-`-prefixed counterparts:

```sh
$ nix develop  # ...or nix-shell
$ gk-configure # pkgs/configure/default.nix
$ gk-decrypt   # pkgs/decrypt/default.nix
$ gk-encrypt   # pkgs/encrypt/default.nix
$ gk-login     # pkgs/login/default.nix
$ gk-theme     # pkgs/theme/default.nix
```

:::

## Build Packages

Packages are exposed as [Flake outputs][flakes-outputs] inside the `packages` output. To build them, use following commands:

```sh
# Using new Nix commands
$ nix build '.#<package-name>'
```

```sh
# ...or with classic Nix commands
$ nix-build ./pkgs -A <package-name>
```

```sh
# You can also build all packages at once with classic Nix commands
$ nix-build ./pkgs
```

To run the packages, either execute the binary stored in `result/bin` after a successful build or use `nix run` instead of `nix build` and `nix-build`.

## Available Packages

- [`gk-configure`][doc-configure]
- [`gk-encrypt` and `gk-decrypt`][doc-encrypt-decrypt]
- [`gk-login`][doc-login]
- [`gk-theme`][doc-theme]
