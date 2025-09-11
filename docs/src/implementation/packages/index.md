# Packages

NixKraken uses several packages to perform actions related to GitKraken configuration handling. Because GitKraken's configuration files also store mutable application state, they cannot be written directly by Nix. Instead, these packages are used to safely read, modify, and write to the JSON configuration files without destroying the state.

These packages are actually Bash scripts bundled using Nix's [`writeShellApplication`](https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-writeShellApplication), which allows to define their runtime dependencies. This approach enables the scripts to be used as Nix packages while also being executable directly, provided all their dependencies are available in the shell environment.

Packages are dynamically exported by the [`pkgs/default.nix`](https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/default.nix) file: adding a directory under `pkgs` with a `default.nix` will automatically make a package (named after the directory) available for use.

> [!NOTE]
>
> When you enter a Nix development shell, the packages are available as their `gk-`-prefixed counterparts:
>
> ```bash
> nix develop
> gk-configure # pkgs/configure/default.nix
> gk-decrypt   # pkgs/decrypt/default.nix
> gk-encrypt   # pkgs/encrypt/default.nix
> gk-login     # pkgs/login/default.nix
> gk-theme     # pkgs/theme/default.nix
> ```

## Available packages

- [`gk-configure`](./configure.md)
- [`gk-encrypt` and `gk-decrypt`](./encrypt-decrypt.md)
- [`gk-login`](./login.md)
- [`gk-theme`](./theme.md)
