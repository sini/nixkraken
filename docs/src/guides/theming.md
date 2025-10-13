[catppuccin-gitkraken]: https://github.com/catppuccin/gitkraken
[doc-caveats]: ../notes/caveats.md#mutability
[doc-install-pkgs]: ../getting-started/install/packages.md
[doc-opt-extrathemes]: ../options/ui.md#uiextrathemes
[doc-opt-profile-theme]: ../options/profiles/ui.md#profilesuitheme
[doc-opt-theme]: ../options/ui.md#uitheme
[gitkraken-themes-doc]: https://help.gitkraken.com/gitkraken-desktop/themes
[gitkraken]: https://www.gitkraken.com/git-client
[jsonc]: https://jsonc.org

# Theming

NixKraken lets you manage [GitKraken][gitkraken]'s UI theme declaratively using the [`ui.extraThemes`][doc-opt-extrathemes], [`ui.theme`][doc-opt-theme] and [`profiles.*.ui.theme`][doc-opt-profile-theme] options.

Using the aforementioned options, you can:

- install custom GitKraken themes
- select the active theme, including built-in ones and custom themes you have added

This guide explains how to use these options, how they relate to GitKraken's theming model, and provides practical examples.

## Common workflows

### Use a built-in GitKraken theme

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

If you simply want a stock GitKraken theme, set [`ui.theme`][doc-opt-theme] (or [`profiles.*.ui.theme`][doc-opt-profile-theme]) to one of its listed valid values (see linked references).

Example to use the light theme:

```nix
{
  programs.nixkraken = {
    enable = true;
    ui.theme = "light";
  };
}
```

> [!NOTE]
>
> Due to the [mutability nature of GitKraken configuration][doc-caveats], you can still change themes within GitKraken. NixKraken ensures that your declarative choices persist on rebuild.

### Use a NixKraken theme

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

NixKraken ships a variety of themes as packages available under `gitkraken-themes`:

<!-- prettier-ignore-start -->
| Theme set | Theme / Variant | Source | Attribute |
| --------- | --------------- | ------ | --------- |
@THEMES_LIST@
<!-- prettier-ignore-end -->

> [!TIP]
>
> Refer to the [installation guide about packages][doc-install-pkgs] to learn how to make themes available to your configuration.

To install themes for GitKraken, add them to [`ui.extraThemes`][doc-opt-extrathemes]:

```nix
{
  programs.nixkraken = {
    enable = true;

    ui.extraThemes = with pkgs.gitkraken-themes; [
      catppuccin.mocha
      dracula.default
    ];
  };
}
```

To enable a theme in GitKraken, use [`ui.theme`][doc-opt-theme] (or [`profiles.*.ui.theme`][doc-opt-profile-theme]):

```nix
{
  programs.nixkraken = {
    enable = true;
    ui.theme = pkgs.gitkraken-themes.catppuccin.mocha.id
  };
}
```

## How GitKraken themes work

GitKraken theme files are [JSONC files][jsonc] that define the colors used throughout the application.

To show up in GitKraken, a theme file must:

- be valid JSONC
- define a unique `meta.name`
- define the theme's `meta.scheme` as `light` or `dark`

If a theme file is invalid, GitKraken skips it and falls back to a default theme.

> [!NOTE]
>
> See [GitKraken's official theme documentation][gitkraken-themes-doc] for further details.

### Create a theme

Following GitKraken's documentation, here are the steps to create a valid theme:

- copy one of the `.jsonc-default` files from `~/.gitkraken/themes` to a new file
- update its `meta.name` and `meta.scheme` values
- update the color tokens in `themeValues`
- ensure the JSONC is valid

```json
{
  "meta": {
    "name": "My Custom Theme",
    "scheme": "dark"
  },
  "themeValues": {
    // Define color tokens here
  }
}
```

### Packaging themes

Here is an example derivation to package [Catppuccin's themes for GitKraken][catppuccin-gitkraken]:

```nix
{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "catppuccin-gitkraken";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "gitkraken";
    rev = version;
    hash = "sha256-df4m2WUotT2yFPyJKEq46Eix/2C/N05q8aFrVQeH1sA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp themes/catppuccin-*.jsonc $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for GitKraken";
    homepage = "https://github.com/catppuccin/gitkraken";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
```

You can replace the source with your theme repository or local files, ensuring the `.jsonc` gets installed in the derivation output (`$out`).

Then, reference the package in [`ui.extraThemes`][doc-opt-extrathemes] and set [`ui.theme`][doc-opt-theme] (or [`profiles.*.ui.theme`][doc-opt-profile-theme]) to the filename of a JSONC theme file:

```nix
{ pkgs, ... }:

{
  programs.nixkraken = {
    enable = true;

    ui = {
      extraThemes = [ pkgs.catppuccin-gitkraken ];
      theme = "catppuccin-mocha.jsonc";
    };
  };
}
```
