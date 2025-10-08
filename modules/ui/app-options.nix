{ lib, ... }:

{
  extraThemes = lib.mkOption {
    type = with lib.types; listOf path;
    default = [ ];
    example = "[ gitkraken-themes.catppuccin.mocha ]";
    description = ''
      Paths to extra themes to install.

      Refer to the [theming guide](../guides/themes.md) for further details.
    '';
  };

  hideFocusStatus = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Hide Focus view related elements from status bar.
    '';
  };

  spellCheck = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable spell checking.
    '';
  };

  toolbarLabels = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show toolbar icon labels.
    '';
  };
}
