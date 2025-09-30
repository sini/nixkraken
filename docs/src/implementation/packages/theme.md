# `gk-theme`

This package provides a command-line interface for a very basic management of GitKraken themes.

It allows to list available themes and install new ones by linking theme files into GitKraken's themes directory.

While it's intended for use during Home Manager activation by the NixKraken module, it can also be used independently for testing.

Although its execution is considered safe, it is possible that theme files are overwritten, resulting in theme data loss. **Please back up your themes before use.**

## Usage

All options are documented by the `--help` flag:

```bash
# Using the raw Bash script
./theme/script.sh --help

# ...or using new Nix commands
nix run '.#theme' -- --help

# ...or from the Nix development shell (nix develop / nix-shell)
gk-theme --help
```

Since the package is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments in [the source file itself](https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/theme/script.sh).
