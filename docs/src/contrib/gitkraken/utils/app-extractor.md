[asar]: https://github.com/electron/asar
[doc-install-pkg]: https://nicolas-goudry.github.io/nixkraken/guide/getting-started/packages.html
[electron]: https://www.electronjs.org
[gh-issue-fn-installables]: https://github.com/NixOS/nix/issues/5316
[nixpkgs-manual-runcommand]: https://nixos.org/manual/nixpkgs/stable/#trivial-builder-runCommand

# GitKraken App Extractor

This utility extracts GitKraken's JavaScript sources, so maintainers can inspect how GitKraken works internally, to help develop NixKraken.

Primary use cases:

- reverse‑engineering the encryption format for secrets files
- auto‑discovering available profile icons, EULA version, etc.
- inspecting configuration file schemas

::: info

This utility is only intended for NixKraken maintainers and contributors, hence it is not distributed via NixKraken’s flake outputs.

:::

## Usage

To extract GitKraken sources, run:

```sh
# From utility's source directory
nix-build
```

```sh
# From repository's root
nix-build ./gitkraken/utils/app-extractor
```

::: info

`nix build` currently [does not support function installables][gh-issue-fn-installables]. Use classic `nix-build` for this utility.

:::

### Selecting a Version

By default, the utility extracts the latest GitKraken version redistributed by NixKraken (as defined in the NixKraken package set you’re building against).

To target a specific version, run:

```sh
nix-build ./gitkraken/utils/app-extractor --argstr version 11.1.0
```

## How It Works

### Context

GitKraken is an [Electron][electron] application. Electron applications bundle their JavaScript inside an <abbr title="Atom Shell Archive Format">ASAR</abbr> archive, which typically contains minified sources.

Electron provides an official [ASAR CLI][asar] that we use to extract and inspect the bundled sources.

### Internals

This is a simple Nix derivation that uses the [`runCommand` build helper][nixpkgs-manual-runcommand] to:

1. Fetch the [GitKraken package from NixKraken][doc-install-pkg]
2. Invoke the `asar` CLI to extract the app archive (e.g., `resources/app.asar`)
3. Expose the extracted files as the derivation's output

The build result is available in the `result` symlink. Inside, you'll find the extracted app contents.

::: info

The extracted files are bundled/minified sources and may be harder to read than the original source files.

:::

## Responsible Use

This utility exists solely to help maintain and improve NixKraken by allowing read‑only inspection of GitKraken’s bundled application code.

Do not modify or redistribute GitKraken code, and do not use the extracted content in ways that would violate GitKraken’s EULA, intellectual property rights, or applicable laws.

::: danger

**We do not endorse any usage that violates applicable laws or terms.**

:::
