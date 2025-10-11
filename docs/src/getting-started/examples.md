[doc-options]: ../options/nixkraken.md
[doc-profiles]: ../guides/profiles.md
[doc-theming]: ../guides/theming.md

# Configuration examples

> [!NOTE]
> These examples cover some of the most common use cases. For a complete list of available settings, please see the [module options reference][doc-options].

## Basic setup

```nix
{
  programs.nixkraken.enable = true;
}
```

## Get rid of initial distractions

```nix
{
  programs.nixkraken = {
    enable = true;

    # Accept the End User License Agreement
    acceptEULA = true;

    # Do not show the introduction tutorial on first launch
    skipTutorial = true;

    # Disable promotional and non-essential notifications
    # WARNING: this will not work without a paid subscription
    notifications = {
      feature = false;
      help = false;
      marketing = false;
    };
  };
}
```

## Manage multiple profiles

> [!NOTE]
>
> Only paid accounts can set profiles beyond the default one.
>
> Read the [dedicated profiles guide][doc-profiles] for further details.

{{#include ../guides/profiles.md:profiles_inheritance}}

## Custom terminal

```nix
{
  programs.nixkraken = {
    enable = true;

    # Define Ghostty as the default external terminal
    tools.terminal.package = pkgs.ghostty;
  };
}
```

## Custom theme

> [!NOTE]
>
> Read the [dedicated theming guide][doc-theming] for further details.

```nix
{
  programs.nixkraken = {
    enable = true;

    ui = {
      extraThemes = [ pkgs.gitkraken-themes.catppuccin.mocha ];
      theme = pkgs.gitkraken-themes.catppuccin.mocha.id;
    };
  };
}
```
