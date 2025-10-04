# Theming

NixKraken lets you manage GitKraken's UI theme declaratively using the [`ui.extraThemes`](../options/ui.md#uiextrathemes), [`ui.theme`](../options/ui.md#uitheme) and [`profiles.*.ui.theme`](../options/profiles/ui.md#profilesuitheme) options.

Using the aforementioned options, you can:

- install custom GitKraken themes
- select the active theme, including built-in ones and custom themes you've added

This guide explains how to use these options, how they relate to GitKraken's theming model, and provides practical examples.

## How GitKraken themes work

GitKraken theme files are [JSONC files](https://jsonc.org/) that define the colors used throughout the application.

To show up in GitKraken, a theme file must:

- be valid JSONC
- define a unique `meta.name`
- define the theme's `meta.scheme` as `light` or `dark`

If a theme file is invalid, GitKraken skips it and falls back to a default theme.

> [!NOTE]
>
> See [GitKraken's official theme documentation](https://help.gitkraken.com/gitkraken-desktop/themes) for further details.

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

## Common workflows

### Use a built-in GitKraken theme

If you simply want a stock GitKraken theme, set [`ui.theme`](../options/ui.md#uitheme) (or [`profiles.*.ui.theme`](../options/profiles/ui.md#profilesuitheme)) to one of its listed valid values.

Example to use the light theme:

```nix
{
  programs.nixkraken = {
    enable = true;
    ui.theme = "light";
  };
}
```

### Use a custom theme

If you have a Nix package that contains theme files, reference the JSONC file(s) under `ui.extraThemes` and set `ui.theme` (or `profiles.*.ui.theme`) to the theme's filename without its extension.name`.

Example using a packaged theme:

```nix
{ pkgs, ... }:

{
  programs.nixkraken = {
    enable = true;

    ui = {
      # Make the theme file available to GitKraken
      extraThemes = [ "${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc" ];

      # Activate the theme
      theme = "catppuccin-mocha";
    };
  };
}
```

## Packaging themes

Here is an example derivation to package [Catppuccin's theme for GitKraken](https://github.com/catppuccin/gitkraken):

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

Then, reference the packaged JSONC file in `ui.extraThemes` and set `ui.theme` (or `profiles.*.ui.theme`) to filename without extension.

## Tips and gotchas

### Coexistence with in-app selection

Due to the [mutability nature of GitKraken configuration](../notes/caveats.md#mutability), you can still change themes within GitKraken. NixKraken ensures that your declarative choices persist on rebuild.

### Non-installing behavior

Because the `ui.extraThemes` option does not install the theme package itself, you must ensure the package providing the JSONC theme file is in scope of your configuration.

### JSONC validity

If a theme doesn't appear in GitKraken, validate the theme file for JSON/JSONC errors.
