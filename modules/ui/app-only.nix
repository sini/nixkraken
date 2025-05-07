{ config, lib, ... }:

let
  cfg = config.programs.nixkraken;

  settings = {
    hideCollapsedWorkspaceTab = cfg.ui.hideWorkspaceTab;

    ui = {
      showToolbarLabels = cfg.ui.enableToolbarLabels;
    };
  };
in
{
  options.programs.nixkraken = {
    ui = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enableToolbarLabels = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Show toolbar icon labels.
            '';
          };

          extraThemes = lib.mkOption {
            type = with lib.types; listOf path;
            default = [ ];
            example = lib.literalExpression "[ \"\${pkgs.catppuccin-gitkraken}/catppuccin-mocha.jsonc\" ]";
            description = ''
              Paths to extra themes to install.
            '';
          };

          hideWorkspaceTab = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Hide workspace tab when closed.
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
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    activation.nixkraken-ui-config =
      lib.hm.dag.entriesAfter "nixkraken"
        [ "nixkraken-top-level" ]
        [
          ''
            gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
          ''
          (lib.optionals (lib.length cfg.ui.extraThemes > 0) [
            ''
              gk-theme -i "${lib.concatStringsSep "," cfg.ui.extraThemes}"
            ''
          ])
        ];
  };
}
