{ lib, ... }:

{
  autocomplete = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable autocomplete suggestions.
      '';
    };

    tabBehavior = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "enter"
          "ignore"
          "navigation"
        ]);
      default = "ignore";
      description = ''
        Behavior of the tab key in the integrated terminal when autocomplete is enabled.

        When set to `enter`, the highlighted suggestion will be entered.

        When set to `navigation`, the next suggestion will be selected.

        When set to `ignore`, the tab key will be sent to the shell.
      '';
    };
  };

  cursor = lib.mkOption {
    type = lib.types.enum [
      "bar"
      "block"
      "underline"
    ];
    default = "block";
    description = ''
      Style of the cursor in the integrated terminal.
    '';
  };

  defaultPath = lib.mkOption {
    type = with lib.types; nullOr path;
    default = null;
    example = lib.literalExpression "\${config.home.homeDirectory}";
    description = ''
      Default directory to open terminal tabs into.
    '';
  };

  fontFamily = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    example = "Liberation Mono";
    description = ''
      Font family to use in the integrated terminal.
    '';
  };

  fontSize = lib.mkOption {
    type = lib.types.ints.positive;
    default = 12;
    description = ''
      Font size to use in the integrated terminal.
    '';
  };

  lineHeight = lib.mkOption {
    type = lib.types.ints.positive;
    default = 1;
    description = ''
      Line height in the integrated terminal.
    '';
  };

  graph = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Show graph panel by default.

        > [!NOTE]
        >
        > This setting only affects terminal tabs when the current directory is a repository.
      '';
    };

    position = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "bottom"
          "left"
          "right"
          "top"
        ]);
      default = "bottom";
      description = ''
        Default graph panel position.

        > [!NOTE]
        >
        > This setting only affects terminal tabs when the current directory is a repository.
      '';
    };
  };
}
