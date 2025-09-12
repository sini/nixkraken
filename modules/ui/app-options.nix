{ lib, ... }:

{
  extraThemes = lib.mkOption {
    type = with lib.types; listOf path;
    default = [ ];
    example = lib.literalExpression "[ \"\${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc\" ]";
    description = ''
      Paths to extra themes to install.

      Note: this option will not install the theme package.
    '';
  };

  spellCheck = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable spell checking.
    '';
  };

  # Defined in app config but used by profiles
  showProjectBreadcrumb = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show workspace breadcrumb in toolbar.
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
