# `gk-theme`

This Bash script provides a command-line interface for a very basic management of GitKraken themes. It allows you to list available themes and install new ones by linking theme files into GitKraken's themes directory. While it's intended for use during Home Manager activation by the nixkraken module, it can also be used independently for testing.

Although its execution is considered safe, it is possible that theme files are overwritten, resulting in theme data loss. **Please back up your themes before use.**

## Usage

All options are documented in the script's help output:

```sh
./theme/script.sh --help
gk-theme --help
```

Since this script is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments.
