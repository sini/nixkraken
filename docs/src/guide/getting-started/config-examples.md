[doc-opts]: ../../reference/nixkraken.md
[doc-profiles]: ../user/profiles.md
[doc-theming]: ../user/theming.md

# Configuration Examples

::: info

These examples cover some of the most common use cases.

For a complete list of available options, please see [NixKraken reference][doc-opts].

:::

## Basic Setup

```nix
{
  programs.nixkraken.enable = true;
}
```

## Get Rid of Initial Distractions

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

## Manage Multiple Profiles

::: warning

Only paid accounts can set profiles beyond the default one.

Read the [dedicated profiles guide][doc-profiles] for further details.

:::

<!-- @include: ../user/profiles.md#profiles_inheritance -->

## Custom Terminal

```nix
{
  programs.nixkraken = {
    enable = true;

    # Define Ghostty as the default external terminal
    tools.terminal.package = pkgs.ghostty;
  };
}
```

## Custom Theme

```nix
{
  programs.nixkraken = {
    enable = true;

    ui = {
      extraThemes = [ pkgs.gitkraken-themes.catppuccin ];
      theme = pkgs.gitkraken-themes.catppuccin.mocha;
    };
  };
}
```

::: tip

Read the [dedicated theming guide][doc-theming] for further details.

:::
