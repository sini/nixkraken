{ lib, ... }:

{
  options = {
    tools = lib.mkOption {
      type = lib.types.submodule {
        options = {
          diff = lib.mkOption {
            type = lib.types.enum [
              "none"
              "use-configured-merge-tool"
              "git-config"
              "araxis-merge"
              "beyond-compare"
              "file-merge"
              "kaleidoscope"
              "kdiff"
              "p4merge"
            ];
            default = "use-configured-merge-tool";
            description = ''
              Set the preferred external diff tool.
              This option will not install the selected tool.
            '';
          };

          editor = lib.mkOption {
            type = lib.types.enum [
              "none"
              "Atom"
              "VS Code"
              "Sublime Text"
              "Intellij Idea CE"
              "Intellij Idea"
            ];
            default = "none";
            description = ''
              Set the preferred external code/text editor.
              This option will not install the selected editor.
            '';
          };

          merge = lib.mkOption {
            type = lib.types.enum [
              "none"
              "git-config"
              "araxis-merge"
              "beyond-compare"
              "file-merge"
              "kaleidoscope"
              "kdiff"
              "p4merge"
            ];
            default = "git-config";
            description = ''
              Set the preferred external merge tool.
              This option will not install the selected tool.
            '';
          };

          terminal = {
            default = lib.mkOption {
              type = lib.types.enum [
                "none"
                "custom"
                "gitkraken"
              ];
              default = "none";
              description = ''
                Set the preferred terminal.
                When `gitkraken` is selected, the bundled GitKraken terminal will be used.
                When `custom` is selected, the package defined by `tools.terminal.package` will
                be installed and used.
              '';
            };

            package = lib.mkOption {
              type = with lib.types; nullOr package;
              default = null;
              example = lib.literalExpression "pkgs.alacritty";
              description = ''
                Custom terminal package to use.
                Must be defined only when `tools.terminal.default` is set to `custom`.
              '';
            };

            bin = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              example = "alacritty";
              description = ''
                Custom terminal binary name.
                Defaults to `''${tools.terminal.package.pname}`.
                Will be prepended by the Nix store path of the package.
              '';
            };

            extraOptions = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              example = [
                "--option cursor.style='Beam'"
                "--title 'Alacritty - GitKraken'"
              ];
              description = ''
                Extra options passed to the custom terminal.
              '';
            };
          };
        };
      };
      default = { };
      description = ''
        External tools settings.
      '';
    };
  };
}
