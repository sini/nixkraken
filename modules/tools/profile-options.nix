{ lib, ... }:

{
  diff = lib.mkOption {
    type = lib.types.enum [
      "none"
      "use-configured-merge-tool"
      "git-config"
    ];
    default = "use-configured-merge-tool";
    description = ''
      Preferred diff tool.
      <!-- scope: profile -->
    '';
  };

  merge = lib.mkOption {
    type = lib.types.enum [
      "none"
      "git-config"
    ];
    default = "git-config";
    description = ''
      Preferred merge tool.
      <!-- scope: profile -->
    '';
  };

  terminal.extraOptions = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    description = ''
      Extra options passed to the terminal.

      ::: info

      This option will not have any effect unless a custom external terminal is set with [`tools.terminal.package`](/reference/tools.md#tools-terminal-package).

      The following variable is available:

      - `%d`: path to the repository on filesystem

      :::
      <!-- scope: profile -->
    '';
  };

  editor = {
    fileExtraOptions = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Extra options passed to the editor when opening a file.

        ::: info

        This option will not have any effect unless a custom external editor is set with [`tools.editor.package`](/reference/tools.md#tools-editor-package).

        The following variables are available:

        - `$REPO_PATH`: path to the repository on filesystem
        - `$FILE_PATH`: path to the file on filesystem

        :::
        <!-- scope: profile -->
      '';
    };

    repoExtraOptions = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Extra options passed to the editor when opening a repository.

        ::: info

        This option will not have any effect unless a custom external editor is set with [`tools.editor.package`](/reference/tools.md#toolseditorpackage).

        The following variable is available:

        - `$REPO_PATH`: path to the repository on filesystem

        :::
        <!-- scope: profile -->
      '';
    };
  };
}
