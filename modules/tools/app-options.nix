{ lib, ... }:

{
  editor.package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = null;
    description = ''
      External code/text editor.
      <!-- scope: global -->
    '';
  };

  terminal.package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = null;
    example = lib.literalExpression "pkgs.alacritty";
    description = ''
      External terminal.

      When set to `null`, the built-in terminal will be used.
      <!-- scope: global -->
    '';
  };
}
