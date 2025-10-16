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

      > [!NOTE]
      >
      > This option will not have any effect unless a custom external terminal is set with [`tools.terminal.package`](@OPTIONS_ROOT@/tools.md#toolsterminalpackage).
      >
      > The following variable is available:
      >
      > - `%d`: path to the repository on filesystem
      <!-- scope: profile -->
    '';
  };

  editor = {
    fileExtraOptions = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Extra options passed to the editor when opening a file.

        > [!NOTE]
        >
        > This option will not have any effect unless a custom external editor is set with [`tools.editor.package`](@OPTIONS_ROOT@/tools.md#toolseditorpackage).
        >
        > The following variables are available:
        >
        > - `$REPO_PATH`: path to the repository on filesystem
        > - `$FILE_PATH`: path to the file on filesystem
        <!-- scope: profile -->
      '';
    };

    repoExtraOptions = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Extra options passed to the editor when opening a repository.

        > [!NOTE]
        >
        > This option will not have any effect unless a custom external editor is set with [`tools.editor.package`](@OPTIONS_ROOT@/tools.md#toolseditorpackage).
        >
        > The following variable is available:
        >
        > - `$REPO_PATH`: path to the repository on filesystem
        <!-- scope: profile -->
      '';
    };
  };
}
