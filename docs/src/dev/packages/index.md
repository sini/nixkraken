[doc-configure]: ./configure.md
[doc-encrypt-decrypt]: ./encrypt-decrypt.md
[doc-login]: ./login.md
[doc-theme]: ./theme.md
[flakes-outputs]: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
[gitkraken]: https://www.gitkraken.com/git-client
[nix-manual]: https://nix.dev/manual/nix/stable
[nixdev-shell]: https://nix.dev/tutorials/first-steps/declarative-shell#declarative-reproducible-envs
[nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable/#preface
[nixpkgs-packagesfromdirectoryrecursive]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.filesystem.packagesFromDirectoryRecursive
[nixpkgs-writeshellapplication]: https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication

# Packages

NixKraken uses several packages to perform actions related to [GitKraken][gitkraken] configuration handling. Because GitKraken's configuration files also store mutable application state, they cannot be written directly by [Nix][nix-manual]. Instead, these packages are used to safely read, modify, and write to the JSON configuration files without destroying the state.

These packages are actually Bash scripts bundled using Nix's [`writeShellApplication`][nixpkgs-writeshellapplication], which allows to define their runtime dependencies. This approach enables the scripts to be used as [Nix packages][nixpkgs-manual] while also being executable directly, provided all their dependencies are available in the shell environment.

Packages are dynamically exported by using the [`packagesFromDirectoryRecursive` function][nixpkgs-packagesfromdirectoryrecursive]. Adding a directory under `pkgs` with a `package.nix` will automatically make a package (named after the directory) available for use.

> [!NOTE]
>
> When you enter a [Nix development shell][nixdev-shell], the packages are available as their `gk-`-prefixed counterparts:
>
> ```bash
> nix develop
> gk-configure # pkgs/configure/default.nix
> gk-decrypt   # pkgs/decrypt/default.nix
> gk-encrypt   # pkgs/encrypt/default.nix
> gk-login     # pkgs/login/default.nix
> gk-theme     # pkgs/theme/default.nix
> ```

## Build packages

Packages are exposed as [Flake outputs][flakes-outputs] inside the `packages` output. To build them, use following commands:

```bash
# Using new Nix commands
nix build '.#<package-name>'
```

```bash
# ...or with classic Nix commands
nix-build ./pkgs -A <package-name>
```

```bash
# You can also build all packages at once with classic Nix commands
nix-build ./pkgs
```

To run the packages, either execute the binary stored in `result/bin` after a successful build or use `nix run` instead of `nix build` and `nix-build`.

## Available packages

- [`gk-configure`][doc-configure]
- [`gk-encrypt` and `gk-decrypt`][doc-encrypt-decrypt]
- [`gk-login`][doc-login]
- [`gk-theme`][doc-theme]
