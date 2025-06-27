# `gk-login`

This package enables to sign in to a GitKraken account from the command line, supporting multiple providers and GitKraken profiles.

It securely handles OAuth tokens, updates the GitKraken configuration, and manages encrypted secrets for both global and profile-specific authentication.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The package **will** modify GitKraken's configuration file as well as secret files (global and profile-specific), and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

## Usage

All options are documented by the `--help` flag:

```bash
./login/script.sh --help
gk-login --help
```

The script itself is extensively documented through comments in [the source file itself](https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/login/script.sh).
