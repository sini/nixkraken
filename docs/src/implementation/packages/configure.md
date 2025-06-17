# `gk-configure`

This Bash script automates the creation and management of GitKraken's configuration files, especially in the context of a [Home Manager][home-manager] installation. While it's intended for use during Home Manager activation by the nixkraken module, it can also be used independently for testing.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The script **will** modify GitKraken's configuration files, and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

## Usage

All options are documented in the script's help output:

```sh
./configure/script.sh --help
gk-configure --help
```

Since this script is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments.
