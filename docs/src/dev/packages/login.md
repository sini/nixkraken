[gitkraken]: https://www.gitkraken.com/git-client
[oauth-tokens]: https://www.oauth.com/oauth2-servers/access-tokens
[pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/login/script.sh

# `gk-login`

This package enables to sign in to a [GitKraken][gitkraken] account from the command line, supporting multiple providers and GitKraken profiles.

It securely handles [OAuth tokens][oauth-tokens], updates the GitKraken configuration, and manages encrypted secrets for both global and profile-specific authentication.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The package **will** modify [GitKraken][gitkraken]'s configuration file as well as secret files (global and profile-specific), and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

## Usage

```txt
@GK_LOGIN_USAGE@
```

## How to run

```bash
# Using the raw Bash script
./pkgs/login/script.sh
```

```bash
# ...or using new Nix commands
nix run '.#login'
```

```bash
# ...or using classic Nix commands
nix-build ./pkgs -A login && ./result/bin/gk-login
```

```bash
# ...or from the Nix development shell (nix develop / nix-shell)
gk-login
```

The script itself is extensively documented through comments in [the source file itself][pkg-source].
