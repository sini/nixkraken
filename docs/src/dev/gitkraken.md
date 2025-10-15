[doc-cache]: ../guides/caching.md
[doc-contrib-gitflow]: ./contributing.md#get-familiar-with-our-git-workflow
[doc-opt-version]: ../options/nixkraken.md#version
[gh-nixpkgs-gitkraken-commits]: https://github.com/NixOS/nixpkgs/commits/master/pkgs/by-name/gi/gitkraken/package.nix
[gh-nixpkgs]: https://github.com/nixos/nixpkgs
[gitkraken]: https://www.gitkraken.com/git-client
[loc-build]: #build
[loc-latest-version]: #latest-and-any-version
[loc-latest]: #latest
[loc-versions]: #handling-versions
[nix-manual-attrs]: https://nix.dev/manual/nix/stable/language/syntax#attrs-literal
[nix-manual-drv]: https://nix.dev/manual/nix/stable/language/derivations.html
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nix-manual-language]: https://nix.dev/manual/nix/stable/language/syntax.html
[nixpkgs-manual-overrideattrs]: https://nixos.org/manual/nixpkgs/stable/#sec-pkg-overrideAttrs
[nixpkgs-manual-passthru]: https://nixos.org/manual/nixpkgs/stable/#chap-passthru
[nixpkgs-manual-unfree]: https://nixos.org/manual/nixpkgs/stable/#sec-allow-unfree
[repo-gitkraken-versions]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/versions.nix
[repo-gitkraken]: https://github.com/nicolas-goudry/nixkraken/blob/main/gitkraken/default.nix

# GitKraken

As mentioned in the [`version` option's documentation][doc-opt-version], NixKraken allows users to select a specific [GitKraken][gitkraken] version to install when using the module. The upside of using this option is that, unlike with [nixpkgs][gh-nixpkgs], such versions are available in a [binary cache][doc-cache] maintained by NixKraken, effectively reducing build and installation time of GitKraken.

Internally, this option relies on a specific [Nix function][nix-manual-functions], which redistributes selected GitKraken versions from a given point in nixpkgs commit history. This page documents how this function work.

## Build

### Specific version

```bash
# Using new Nix commands
nix build '.#gitkraken-v11-1-0'
```

```bash
# ...or with classic Nix commands
nix-build ./gitkraken -A gitkraken-v11-1-0
```

### Latest version

```bash
# Using new Nix commands
nix build '.#gitkraken'
```

```bash
# ...or with classic Nix commands
nix-build ./gitkraken
```

## Redistributing GitKraken

To redistribute [GitKraken][gitkraken], the main file of interest is [`gitkraken/default.nix`][repo-gitkraken].

It defines a [Nix function][nix-manual-functions] which takes an optional `version` argument, and either returns a [derivation][nix-manual-drv] of:

- GitKraken at selected `version`
- latest GitKraken version available for redistribution

Either way, the derivation source will always be [nixpkgs][gh-nixpkgs].

_To learn how versions are selected, refer to the specific section about [version handling][loc-versions]._

As an added nicety, and to always provide the best user experience, GitKraken is automatically added to [allowed unfree packages][nixpkgs-manual-unfree] when building, so that users do not have to do it themselves.

Implementation-wise, the behavior is slightly different, based on whether the `version` argument is provided or not.

### Specific version

When `version` argument is set, the function will:

- validate that said version exists
- import nixpkgs at the matching commit for this version
- output the GitKraken derivation from nixpkgs

> [!NOTE]
>
> If the selected `version` is not valid, an informative error will be thrown, explaining that the `version` is invalid and providing the list of valid versions.

### Latest and any version

When `version` argument is omitted, the function will use the same behavior used for specific versions to output the [latest version][loc-latest] available for redistribution.

Additionally, it will [override][nixpkgs-manual-overrideattrs] the nixpkgs derivation to add a [`passthru` attribute][nixpkgs-manual-passthru] which exposes all GitKraken versions available for redistribution.

This method allows two things:

1. Install the latest available GitKraken version

   ```nix
   nixkraken.packages.gitkraken
   ```

2. Install any redistributed version of GitKraken

   ```nix
   nixkraken.packages.gitkraken.gitkraken-v11-1-0 # Or any other supported version
   ```

> [!NOTE]
>
> We use the dash notation for versions instead of the dot notation, because dots are used to access child attributes in [Nix language][nix-manual-language].

## Handling versions

In order to select the right [nixpkgs][gh-nixpkgs] commits for redistributed [GitKraken][gitkraken] versions, a mapping is maintained in [`gitkraken/versions.nix`][repo-gitkraken-versions].

This mapping is an [attribute set][nix-manual-attrs] with attributes names set to a GitKraken version available in nixpkgs:

```nix
{
  "11.1.0" = {
    commit = "...";
    hash = "...";
  };
}
```

As showcased above, each version attribute is itself an attribute set with the following required attributes:

- `commit`: the nixpkgs commit SHA where this GitKraken version is available
- `hash`: the nixpkgs source hash

### Latest

As mentioned in the [redistribution section][loc-latest-version], we also maintain a moving flag which indicates which redistributed version is the latest.

This flag is defined using a boolean attribute named `latest`, which exists only in the attribute set defining the latest version available:

```nix
{
  "11.1.0" = {
    commit = "...";
    hash = "...";
    latest = true;
  };
}
```

> [!WARNING]
>
> Since there must be only one latest version, the [build][loc-build] will fail if the flag is defined several times (or not at all).

### Add a new version

Adding a new GitKraken version is pretty straightforward:

- create a new attribute named after the version (using dot notation: `MAJOR.MINOR.PATCH`)
- look at the [GitKraken derivation file history in nixpkgs][gh-nixpkgs-gitkraken-commits]
- set `commit` to the commit SHA matching the update to given version

  ![Example: GitKraken package update to v11.1.0 in nixpkgs](./assets/nixpkgs-gitkraken-commit-history.png 'Example: GitKraken package update to v11.1.0 in nixpkgs')

- set `hash` to an empty string `""`
- [build GitKraken][loc-build], it will fail but output the expected `hash` value
- set `hash` to the expected value
- build again
- [commit, push, open PR][doc-contrib-gitflow]
