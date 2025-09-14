{ lib, ... }:

{
  eol = lib.mkOption {
    type = lib.types.enum [
      "CRLF"
      "LF"
    ];
    default = "LF";
    description = ''
      End of line character to use in the editor.
    '';
  };

  fontFamily = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    example = "Liberation Mono";
    description = ''
      Font family to use in the editor.
    '';
  };

  fontSize = lib.mkOption {
    type = lib.types.ints.positive;
    default = 12;
    description = ''
      Font size to use in the editor.
    '';
  };

  lineNumbers = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show line numbers in the editor.
    '';
  };

  syntaxHighlight = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable syntax highlighting in the editor.
    '';
  };

  tabSize = lib.mkOption {
    type = lib.types.ints.positive;
    default = 4;
    description = ''
      Size of the indentation in the editor.
    '';
  };

  wrap = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable word wrap in the editor.
    '';
  };
}
