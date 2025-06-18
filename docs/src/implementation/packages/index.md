[gh-pkgs-default]: https://github.com/nicolas-goudry/nixkraken/tree/main/pkgs/default.nix
[noogle-writeshellapp]: https://noogle.dev/f/pkgs/writeShellApplication

# Packages

Nixkraken uses several packages to perform actions related to GitKraken configuration handling.

These packages are actually Bash scripts bundled using Nix's [`writeShellApplication`][noogle-writeshellapp], which allows to define their runtime dependencies. This approach enables the scripts to be used as Nix packages while also being executable directly, provided all their dependencies are available in the shell environment.

Packages are dynamically exported by the [`pkgs/default.nix`][gh-pkgs-default] file: adding a directory under `pkgs` with a `default.nix` will automatically make a package (named after the directory) available for use.

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
