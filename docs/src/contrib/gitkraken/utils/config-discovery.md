[doc-deep-json-diff]: ./deep-json-differ.md
[doc-install-pkg]: https://nicolas-goudry.github.io/nixkraken/guide/getting-started/packages.html
[gh-issue-fn-installables]: https://github.com/NixOS/nix/issues/5316
[loc-select-version]: #selecting-a-version
[nixpkgs-manual-writeshellapp]: https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication

# GitKraken Config Discovery

This utility is a Bash script, bundled with the [`writeShellApplication` build helper][nixpkgs-manual-writeshellapp], which allows for easy and interactive GitKraken configuration discovery.

When run, the script will launch GitKraken as a child process and watch for changes to GitKraken configuration files. Internally, it uses the [deep-json-diff][doc-deep-json-diff] Python utility to diff the updated configuration file with its previous content and output the changes.

This allows you to interact with the GitKraken UI in order to discover the configuration keys behind checkboxes, input fields and such that control GitKraken settings.

::: info

This utility is intended for NixKraken maintainers and contributors and is not distributed via NixKraken’s flake outputs.

:::

## Build

```sh
# From utility's source directory
nix-build
```

```sh
# From repository's root
nix-build ./gitkraken/utils/config-discovery
```

::: info

`nix build` currently [does not support function installables][gh-issue-fn-installables]. Use classic `nix-build` for this utility.

:::

### Selecting a Version

By default, the utility uses the latest [GitKraken version redistributed by NixKraken][doc-install-pkg] (as defined in the NixKraken package set you’re building against).

To use a specific version, run:

```sh
nix-build ./gitkraken/utils/config-discovery --argstr version 11.1.0
```

## Usage

By default, the utility watches the main application configuration file (i.e., `~/.gitkraken/config`):

```sh
./result/bin/gk-config-discovery
```

Additionally, passing a profile identifier as argument allows to watch for this profile-specific configuration (i.e., `~/.gitkraken/profiles/<profileId>/profile`):

```sh
# Default profile
./result/bin/gk-config-discovery d6e5a8ca26e14325a4275fc33b17e16f
```

::: warning

If GitKraken is already running, the utility will silently fail to launch it and watch for configuration changes anyway.

This means that if you selected a [specific version of GitKraken][loc-select-version], it will not have any effect until you close GitKraken and re-run the utility.

:::
