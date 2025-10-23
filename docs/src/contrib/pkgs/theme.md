[gitkraken]: https://www.gitkraken.com/git-client
[hm-activation]: https://nix-community.github.io/home-manager/index.xhtml#sec-internals-activation
[pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/theme/script.sh

# `gk-theme`

This package provides a command-line interface for a very basic management of [GitKraken][gitkraken] themes.

It allows to list available themes and install new ones by linking theme files into GitKraken's themes directory.

While it is intended for use during [Home Manager activation][hm-activation] by the NixKraken module, it can also be used independently for testing.

Although its execution is considered safe, it is possible that theme files are overwritten, resulting in theme data loss. **Please back up your themes before use.**

## Usage

```txt
@GK_THEME_USAGE@
```

## How to Run

```bash
# Using the raw Bash script
./pkgs/theme/script.sh
```

```bash
# ...or using new Nix commands
nix run '.#theme'
```

```bash
# ...or using classic Nix commands
nix-build ./pkgs -A theme && ./result/bin/gk-theme
```

```bash
# ...or from the Nix development shell (nix develop / nix-shell)
gk-theme
```

Since the package is typically run during [Home Manager activation][hm-activation], it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments in [the source file itself][pkg-source].
