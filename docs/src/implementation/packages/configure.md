[home-manager]: https://nix-community.github.io/home-manager

# `gk-configure`

This package automates the creation and management of GitKraken's configuration files, especially in the context of a [Home Manager][home-manager] installation.

While it's intended for use during Home Manager activation by the Nixkraken module, it can also be used independently for testing.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The package **will** modify GitKraken's configuration files, and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

## Usage

All options are documented by the `--help` flag:

```bash
./configure/script.sh --help
gk-configure --help
```

Since the package is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script is extensively documented through comments.
