{ lib, ... }:

{
  extraThemes = lib.mkOption {
    type = with lib.types; listOf path;
    default = [ ];
    example = lib.literalExpression "[ \"\${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc\" ]";
    description = ''
      Paths to extra themes to install.

      Refer to the [theming guide](../guides/themes.md) for real-world usage.

      > [!WARNING]
      >
      > This option will not install the theme package.
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
