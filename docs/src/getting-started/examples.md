# Configuration examples

> [!NOTE]
> These examples cover some of the most common use cases. For a complete list of all available settings, please see the [module options reference](../options/nixkraken.md).

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

    # Don't show the introductory tour on first launch
    skipTour = true;

    # Disable promotional and non-essential notifications
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

    # Configure the default/personal profile
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

        # You can override default settings in profiles
        ui.theme = "dark";
      }
    ];
  };
}
```

## Follow Git configuration

```nix
{
  programs.nixkraken = {
    enable = true;

    # Use local SSH agent (this is the default)
    ssh.useLocalAgent = true;

    # Configure GPG signing settings to follow Git ones
    gpg = {
      signingKey = config.programs.git.signing.key;
      signCommits = config.programs.git.signing.signByDefault;
      signTags = config.programs.git.signing.signByDefault;
    };

    # Configure user details to follow Git ones
    user = {
      email = config.programs.git.userEmail;
      name = config.programs.git.userName;
    };
  };
}
```

## Custom terminal

```nix
{
  programs.nixkraken = {
    enable = true;

    # Define Ghostty as the default external terminal
    tools.terminal = {
      default = "custom";
      package = pkgs.ghostty;
    };
  };
}
```

## Custom theme

```nix
{
  programs.nixkraken = {
    enable = true;

    ui = {
      # Add Mocha variant of Catppuccin theme for GitKraken
      extraThemes = [ "${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc" ];

      # Enable extra theme
      theme = "catppuccin-mocha.jsonc";
    };
  };
}
```
