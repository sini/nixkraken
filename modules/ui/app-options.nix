{ lib, ... }:

{
  extraThemes = lib.mkOption {
    type = with lib.types; listOf path;
    default = [ ];
    example = "[ gitkraken-themes.catppuccin ]";
    description = ''
      Paths to extra themes to install.

      > [!NOTE]
      >
      > Refer to the [theming guide](../guides/theming.md) for further details.
      <!-- scope: global -->
    '';
  };

  hideFocusStatus = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Hide Focus view related elements from status bar.
      <!-- scope: global -->
    '';
  };

  spellCheck = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable spell checking.
      <!-- scope: global -->
    '';
  };

  toolbarLabels = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show toolbar icon labels.
      <!-- scope: global -->
    '';
  };
}
