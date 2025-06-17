[gh-pkgs-default]: https://github.com/nicolas-goudry/nixkraken/tree/main/pkgs/default.nix

# Packages

Nixkraken packages are Bash scripts bundled using Nix's `writeShellApplication`, which allows to define their runtime dependencies. This approach enables the scripts to be used as Nix packages while also being executable directly, provided all their dependencies are available in the shell environment.

Packages are exported by the [`default.nix`][gh-pkgs-default] file dynamically: adding a directory under `pkgs` with a `default.nix` will automatically make a package (named after the directory) available for use.

> [!NOTE]
>
> When you enter a Nix development shell, the packages are available as their `gk-`-prefixed counterparts:
>
> ```sh
> nix develop
> gk-configure
> gk-decrypt
> gk-encrypt
> gk-login
> gk-theme
> ```
