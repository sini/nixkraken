[gitkraken]: https://www.gitkraken.com/git-client
[hm-activation]: https://nix-community.github.io/home-manager/index.xhtml#sec-internals-activation
[hm]: https://nix-community.github.io/home-manager
[pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/configure/script.py

# `gk-configure`

This package automates the creation and management of [GitKraken][gitkraken]'s configuration files, especially in the context of a [Home Manager][hm] installation.

While it is intended for use during [Home Manager activation][hm-activation] by the NixKraken module, it can also be used independently for testing.

::: danger **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION**

The package **will** modify [GitKraken][gitkraken]'s configuration files, and loss of configuration is a possible outcome, although we strive to make it as safe as possible.

Please back up your configuration before use.

:::

## Usage

```txt
@GK_CONFIGURE_USAGE@
```

## How to Run

```sh
# Using the raw Bash script
$ ./pkgs/configure/script.sh
```

```sh
# ...or using new Nix commands
$ nix run '.#configure'
```

```sh
# ...or using classic Nix commands
$ nix-build ./pkgs -A configure && ./result/bin/gk-configure
```

```sh
# ...or from the Nix development shell (nix develop / nix-shell)
$ gk-configure
```

Since the package is typically run during [Home Manager activation][hm-activation], it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

For further details, refer to the [actual script code][pkg-source].
