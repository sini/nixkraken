[doc-contrib-gitflow]: ./contributing.md#get-familiar-with-our-git-workflow
[doc-theme-pkg]: ./packages/theme.md
[doc-theming]: ../guides/theming.md#use-a-nixkraken-theme
[gitkraken]: https://www.gitkraken.com/git-client
[hm-activation]: https://nix-community.github.io/home-manager/index.xhtml#sec-internals-activation
[hm]: https://nix-community.github.io/home-manager/index.xhtml
[jsonc]: https://jsonc.org
[loc-dummy-drv]: #dummy-derivation
[loc-make-set-variants]: #make-set-variants
[loc-theme-sets]: #theme-sets
[loc-theme-variants]: #theme-variants
[nix-manual-drv]: https://nix.dev/manual/nix/stable/language/derivations.html
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[nixpkgs-manual-passthru]: https://nixos.org/manual/nixpkgs/stable/#chap-passthru
[nixpkgs-manual-src-hash]: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-fetchers-updating-source-hashes
[nixpkgs-pkgsdirrec]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.filesystem.packagesFromDirectoryRecursive
[repo-themes-default]: https://github.com/nicolas-goudry/nixkraken/blob/main/themes/default.nix
[repo-themes-root]: https://github.com/nicolas-goudry/nixkraken/blob/main/themes

# Themes

Beyond the [Home Manager][hm] module, NixKraken provides complementary packages for [GitKraken][gitkraken] themes. Such packages are stored in the [`themes` directory][repo-themes-root] and are exposed in the `packages.gitkraken-themes` [Flake][nixos-wiki-flakes] output.

For usage within NixKraken and a list of currently available themes, please refer to the [theming guide][doc-theming].

## Build

The main entrypoint to build the themes is the [`default.nix` file][repo-themes-default], which is a "dummy" [derivation][nix-manual-drv] that exposes all themes through the [`passthru` attribute][nixpkgs-manual-passthru]:

This allows for easy theme selection by referring to their attribute name:

```bash
# Build Catppuccin theme set using new Nix commands
nix build '.#gitkraken-themes.catppuccin'
```

```bash
# ...or classic Nix commands
nix-build ./themes -A catppuccin
```

## Directory structure

Here is an overview of the [`themes` directory][repo-themes-root] structure:

```bash
themes
├── sets
│   ├── catppuccin.nix
│   ├── color-blind.nix
│   ├── dracula.nix
│   └── ...
└── default.nix
```

All themes are located under `themes/sets` in `.nix` files named after the theme. The filename will be used (without its extension) to identify the themes in the main entrypoint.

## Internals

Each theme is a valid [Nix function][nix-manual-functions] which must return a [Nix derivation][nix-manual-drv]. Theme derivations should comply with the following rules:

1. Install [JSONC][jsonc] theme variants files in the `$out` directory

   This is needed because themes are used in conjunction with the [`gk-theme` package][doc-theme-pkg], which looks for JSONC files at the root of the lookup paths it is given.

2. Define a [`passthru` attribute][nixpkgs-manual-passthru] which exposes the filename used by each theme variant

   This is needed because [GitKraken][gitkraken] expects the `ui.theme` configuration setting to be set to the theme filename. If the theme has no variants, it should use the `passthru.default` attribute.

There are currently two ways to define themes, depending on if the theme has multiple variants or not.

### Single variant

For single variant themes, the derivation should look something like this:

```nix
{{#include ../../../themes/sets/tokyo-night.nix}}
```

### Multiple variants

As for multiple variants themes, the derivation is a bit more complicated, since it allows an optional `withVariants` argument and must validate it against valid variants.

Find below an example implementation for the Catppuccin theme:

```nix
{{#include ../../../themes/sets/catppuccin.nix}}
```

## Maintenance

### Add new themes

To add a new theme, the most simple way is to copy one of the existing themes (single or multiple variants, based on your needs), and modify it for the new theme.

> [!WARNING]
>
> Be aware that multiple GitKraken themes cannot use the same filename, since when installed together they will overwrite each other.

### Updating themes

When a theme has a new release, here are the steps to follow:

- ensure that the location of the theme files didn't change within the source repository
  - in such case, the theme derivation should be updated accordingly
- ensure that the name of the theme files didn't change within the source repository
  - in such case, the theme derivation should be updated accordingly
- update the `version` attribute of the theme derivation
- update the `hash` attribute used by the `src` fetcher (most likely `fetchFromGitHub`):
  - the most simple way is to [set the `hash` to an empty string][nixpkgs-manual-src-hash]
  - build the theme (it will fail, this is expected)
  - copy the expected hash provided by the error message into the derivation
- [commit, push, PR][doc-contrib-gitflow]
