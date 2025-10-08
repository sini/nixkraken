# Configuration examples

> [!NOTE]
> These examples cover some of the most common use cases. For a complete list of available settings, please see the [module options reference](../options/nixkraken.md).

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

    # Don't show the introduction tutorial on first launch
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

> [!IMPORTANT]
> Only paid accounts can set profiles beyond the default one.

```nix
{
  programs.nixkraken = {
    enable = true;

    # Configure the default profile
    user = {
      name = "Personal Name";
      email = "personal@email.com"
    };

    # Configure a separate, named profile for work
    profiles = [
      {
        name = "Work";

        user = {
          name = "Work Name";
          email = "work@email.com";
        };

        ui.theme = "dark";
      }
    ];
  };
}
```

### Inherit options from default profile

```nix
{
  # Notice the "rec" keyword? This is a recursive attribute set, allowing us to
  # reuse previously defined keys anywhere inside this attribute set.
  programs.nixkraken = rec {
    enable = true;

    # Configure graph columns
    graph = {
      compact = true;
      showAuthor = true;
      showDatetime = true;
      showMessage = true;
      showRefs = false;
      showSHA = false;
      showGraph = true;
    };

    profiles = [
      {
        # Use same graph settings as default profile
        inherit graph;

        name = "Other profile";
      }
    ];
  };
}
```

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
> Read the [dedicated theming guide](../guides/themes.md) for further details.

```nix
{
  programs.nixkraken = {
    enable = true;

    ui = {
      # Add Mocha variant of Catppuccin theme for GitKraken
      extraThemes = [ "${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc" ];

      # Enable extra theme
      theme = "catppuccin-mocha";
    };
  };
}
```
