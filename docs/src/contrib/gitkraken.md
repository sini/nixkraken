[doc-cache]: ../guide/user/caching.md
[doc-contrib-gitflow]: ./contributing.md#get-familiar-with-our-git-workflow
[doc-opt-version]: ../reference/nixkraken.md#version
[doc-pkg-install-gitkraken]: ../guide/getting-started/packages.md#gitkraken-package
[doc-pkg-login]: ./pkgs/login.md
[electron]: https://www.electronjs.org
[flakes-outputs]: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
[garnix]: https://garnix.io
[gh-asar]: https://github.com/electron/asar
[gh-nixpkgs-gitkraken-commits]: https://github.com/NixOS/nixpkgs/commits/master/pkgs/by-name/gi/gitkraken/package.nix
[gh-nixpkgs]: https://github.com/nixos/nixpkgs
[gitkraken]: https://www.gitkraken.com/git-client
[loc-build-latest]: #latest-version
[loc-build-specific]: #specific-version
[nix-manual-attrs]: https://nix.dev/manual/nix/stable/language/syntax#attrs-literal
[nix-manual-drv]: https://nix.dev/manual/nix/stable/language/derivations.html
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nixpkgs-manual-overrideattrs]: https://nixos.org/manual/nixpkgs/stable/#sec-pkg-overrideAttrs
[nixpkgs-manual-passthru]: https://nixos.org/manual/nixpkgs/stable/#chap-passthru
[nixpkgs-manual-unfree]: https://nixos.org/manual/nixpkgs/stable/#sec-allow-unfree
[prettier]: https://prettier.io
[repo-gitkraken-extract]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/extract.nix
[repo-gitkraken-versions]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/versions.nix
[repo-gitkraken]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/default.nix

# GitKraken

This page explains how NixKraken redistributes specific [GitKraken][gitkraken] versions by importing matching commits from [nixpkgs][gh-nixpkgs].

It documents how to build the packages, how versions are tracked, and the contributor workflow for adding new versions.

See the [`version` option documentation][doc-opt-version] for how users select a GitKraken version. Using that option lets NixKraken provide prebuilt GitKraken binaries from its [binary cache][doc-cache], reducing build and install time compared with relying on nixpkgs.

## Build

### Latest Version

```sh
# Using new Nix commands
$ nix build '.#gitkraken'
```

```sh
# ...or with classic Nix commands
$ nix-build ./gitkraken
```

### Specific Version

::: warning

These dashed attributes are primarily for maintainers and CI to prebuild and cache each redistributed version.

[Users should install the plain `gitkraken` derivation instead][doc-pkg-install-gitkraken].

:::

```sh
# Using new Nix commands
$ nix build '.#gitkraken.gitkraken-v11-1-0'
```

```sh
# ...or with classic Nix commands
$ nix-build ./gitkraken -A gitkraken-v11-1-0
```

## How Redistribution Works

[`gitkraken/default.nix`][repo-gitkraken] defines a [Nix function][nix-manual-functions] that accepts an optional `version` argument. Based on this argument, the behavior will differ and either return a [derivation][nix-manual-drv] for the latest version or a specific version of GitKraken.

If `version` is provided, the function:

- validates the version
- imports the corresponding nixpkgs commit
- returns the GitKraken derivation for that version

If `version` is omitted, the function:

- imports the nixpkgs commit for the currently redistributed latest version
- [overrides the derivation][nixpkgs-manual-overrideattrs] to expose all redistributed versions via a [`passthru` attribute][nixpkgs-manual-passthru]
- returns the `latest` derivation

::: info About `passthru`

The Flake uses derivations exposed by the `passthru` attribute to surface them as [Flake outputs][flakes-outputs] (e.g., `gitkraken-v<dashed-version>`), which [Garnix CI][garnix] can target to build and populate the [binary cache][doc-cache].

:::

The function also automatically adds GitKraken to [allowed unfree packages][nixpkgs-manual-unfree] for the build, so users do not have to set `allowUnfreePredicate` manually when installing NixKraken.

## Handling Versions

The mapping of redistributed versions is maintained in [`gitkraken/versions.nix`][repo-gitkraken-versions].

Each version entry is an [attribute set][nix-manual-attrs] with required fields:

- `commit`: the nixpkgs commit SHA where this GitKraken version is packaged
- `hash`: the nixpkgs source hash for that derivation

Additionally, to keep track of the latest version of GitKraken, **a single version entry** can define the `latest` attribute.

Example entry:

```nix
{
  "11.1.0" = {
    commit = "...";
    hash = "...";
    latest = true; # Only on the one latest entry
  };
}
```

::: warning

The [build][loc-build-latest] will fail if the `latest` flag is missing or present more than once.

:::

### Add a New Redistributed Version

Below are the steps required to add a new version of GitKraken to redistribute:

**1. Add a new attribute for version**

Use the dotted version as key (e.g., `"11.2.0" = { ... }`) and set:

- `commit` to the nixpkgs commit SHA where the GitKraken package was updated
- `hash` temporarily to the empty string `""`

::: tip How to find the commit SHA?

Look at [GitKraken's package history][gh-nixpkgs-gitkraken-commits] and copy the commit SHA that corresponds to the update.

![GitKraken package update to v11.1.0 in nixpkgs](./assets/nixpkgs-gitkraken-commit-history.png 'GitKraken package update to v11.1.0 in nixpkgs')

The full commit SHA can be copied by using the button on the right of the short SHA (`36dcda8`).

:::

**2. Obtain the correct `hash`**

- attempt to [build the redistributed derivation][loc-build-specific] - _this will fail and print the expected hash_
- use the printed expected hash value to update `hash`
- re-run the build to confirm success

**3. Update `latest`**

If this new version should be the redistributed latest, add `latest = true` to the new entry and remove `latest` from the previous latest.

::: warning

Ensure only one entry has `latest = true`.

:::

**4. Commit, push and open a PR following the [contribution workflow][doc-contrib-gitflow]**

## Extracting GitKraken Application Code

GitKraken is packaged as an [Electron][electron] application which bundles JavaScript in an <abbr title="Atom Shell Archive Format">ASAR</abbr> archive. Electron provides an official [CLI to work on ASAR archives][gh-asar].

We provide a small [Nix derivation that extracts the ASAR][repo-gitkraken-extract] and prettifies the JavaScript (using [Prettier][prettier]) for easier inspection. This is useful when maintaining the [`gk-login` package][doc-pkg-login].

We only provide classic Nix commands for this, to avoid having to distribute this derivation through NixKraken's Flake:

```sh
# Extract the specified GitKraken version
$ nix-build ./gitkraken/extract.nix --argstr version 11.1.0
```

The command outputs the ASAR content in `result`, with all GitKraken source code files prettified.

::: info

The extracted files are the bundled sources and may be harder to read than original source files.

:::
