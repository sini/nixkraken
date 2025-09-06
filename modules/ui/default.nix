{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  commonOpts = import ./common-options.nix args;

  settings = {
    hideCollapsedWorkspaceTab = cfg.ui.hideWorkspaceTab;

    ui = {
      showToolbarLabels = cfg.ui.enableToolbarLabels;
    };
  };
in
{
  options.programs.nixkraken.ui = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // commonOpts;
    };
    default = { };
    description = ''
      UI settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.nixkraken._submoduleSettings.ui = settings;
  };
}
