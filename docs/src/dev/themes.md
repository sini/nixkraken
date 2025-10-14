[doc-contrib-gitflow]: ./contributing.md#get-familiar-with-our-git-workflow
[doc-opt-extrathemes]: ../options/ui.md#uiextrathemes
[doc-theme-pkg]: ./packages/theme.md
[doc-theming]: ../guides/theming.md#use-a-nixkraken-theme
[gitkraken]: https://www.gitkraken.com/git-client
[hm]: https://nix-community.github.io/home-manager/index.xhtml
[jsonc]: https://jsonc.org
[loc-build]: #build
[loc-multiple-variants]: #multiple-variants
[loc-single-variant]: #single-variant
[nix-manual-drv]: https://nix.dev/manual/nix/stable/language/derivations.html
[nix-manual-functions]: https://nix.dev/manual/nix/stable/language/syntax#functions
[nix-store]: https://nix.dev/manual/nix/stable/store/index.html
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[nixpkgs-manual-fetchfromgh]: https://nixos.org/manual/nixpkgs/stable/#fetchfromgithub
[nixpkgs-manual-passthru]: https://nixos.org/manual/nixpkgs/stable/#chap-passthru
[nixpkgs-manual-src-hash]: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-fetchers-updating-source-hashes
[repo-themes-default]: https://github.com/nicolas-goudry/nixkraken/blob/main/themes/default.nix
[repo-themes-root]: https://github.com/nicolas-goudry/nixkraken/blob/main/themes

# Themes

Beyond the [Home Manager][hm] module, NixKraken provides complementary packages for [GitKraken][gitkraken] themes. These reside under the [`themes` directory][repo-themes-root] and are exposed via the `packages.gitkraken-themes` [Flake][nixos-wiki-flakes] output.

For end-user usage within NixKraken and the list of available themes, see the [theming guide][doc-theming].

## Build

The main entry point for building themes is [`themes/default.nix`][repo-themes-default]. It defines a "dummy" [derivation][nix-manual-drv] that exposes all theme sets as attributes of its [`passthru` attribute][nixpkgs-manual-passthru].

Example builds:

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

All themes lives in `themes/sets` in `.nix` files named after the theme. The basename (without `.nix`) is the attribute used for theme selection in the entry point.

## Internals

Each theme is a [Nix function][nix-manual-functions] that returns a [derivation][nix-manual-drv]. Theme derivations must:

1. Install [JSONC][jsonc] files to the derivation output root (`$out`)

   - required because the [`ui.extraThemes` option][doc-opt-extrathemes] passes the [Nix store][nix-store] path to the [`gk-theme` package][doc-theme-pkg], which expects JSONC files at the directory root.

2. Expose variant filenames via [`passthru` attribute][nixpkgs-manual-passthru]

   - define a `passthru` attribute that maps the logical variant to the exact JSONC filename GitKraken expects in `ui.theme`
   - for single-variant themes, set `passthru.default` to the filename

There are two common patterns, depending on whether the theme has a [single variant][loc-single-variant] or [multiple variants][loc-multiple-variants].

### Single variant

For single variant themes, the derivation is straightforward:

```nix
{{#include ../../../themes/sets/tokyo-night.nix}}
```

### Multiple variants

Multi-variant themes typically accept an optional `withVariants` argument, validate it against supported variants, and output multiple JSONC files accordingly.

Example (Catppuccin):

```nix
{{#include ../../../themes/sets/catppuccin.nix}}
```

## Maintenance

### Add new themes

The simplest approach is to copy an existing theme with a similar variant pattern (single vs multiple) and adapt it.

> [!WARNING]
>
> GitKraken theme filenames must be unique across installed themes. If two themes install the same filename, they will overwrite each other.

Recommended checklist:

- [ ] Choose a base (single or multiple variants) theme as template
- [ ] Update `name`, `version`, `src` and `meta`
- [ ] Update `themePath` (single variant themes only)
- [ ] Update `defaultVariants` list (multiple variants themes only)
- [ ] Ensure the JSONC files are copied from the correct source location to `$out`
- [ ] [Build the themes][loc-build] to validate your theme

### Updating themes

When a theme releases a new version:

- bump the version attribute
- update the src fetcher hash (e.g., for [`fetchFromGitHub`][nixpkgs-manual-fetchfromgh])
  - easiest path: set `hash = ""` per the [manual][nixpkgs-manual-src-hash]
  - build once (expected to fail), copy the reported hash into the derivation
- verify file locations in the source repository
  - if paths changed, update the derivation's `installPhase` accordingly
- verify file names in the source repository
  - if names changed, update the derivation's accordingly (`themePath` or `defaultVariants`)
- rebuild and verify the passthru still matches the installed filenames
- [Commit, push, open PR][doc-contrib-gitflow].
