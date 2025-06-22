# Configuration examples

## Basic setup

This setup will install GitKraken and configure it with default values, as if it was installed directly in `home.packages`.

```nix
{
  programs.nixkraken.enable = true;
}
```

## Get rid of initial distractions

This setup will automatically:

- accept GitKraken [End User License Agreement](https://www.gitkraken.com/eula)
- mark the tour guide as done
- disable all "irrelevant" notifications

```nix
{
  programs.nixkraken = {
    enable = true;
    acceptEULA = true;
    skipTour = true;
    notifications = {
      feature = false;
      help = false;
      marketing = false;
    };
  };
}
```

## Follow Git configuration

This setup will use the configuration from [`programs.git`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable) to setup relevant parts of GitKraken configuration.

> [!NOTE]
> Unless explicitly disabled by `ssh.useLocalAgent`, GitKraken is configured to use the local SSH agent by default.

```nix
{
  programs.nixkraken = {
    enable = true;
    ssh.useLocalAgent = true; # This is the default

    gpg = {
      signingKey = config.programs.git.signing.key;
      signCommits = config.programs.git.signing.signByDefault;
      signTags = config.programs.git.signing.signByDefault;
    };

    user = {
      email = config.programs.git.userEmail;
      name = config.programs.git.userName;
    };
  };
}
```

## Custom terminal

This setup will configure the default external terminal to use.

```nix
{
  programs.nixkraken = {
    enable = true;

    tools.terminal = {
      default = "custom";
      package = pkgs.ghostty;
    };
  };
}
```

## Custom theme

This setup will install a given theme file in GitKraken's themes directory and use it by default.

```nix
{
  programs.nixkraken = {
    enable = true;

    ui = {
      extraThemes = [ "${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc" ];
      theme = "catppuccin-mocha.jsonc";
    };
  };
}
```
