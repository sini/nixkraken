{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  profileOpts = import ./profile-options.nix args;

  settings = {
    hideFocusViewStatusBar = cfg.ui.hideFocusStatus;

    ui = {
      showToolbarLabels = cfg.ui.toolbarLabels;
      spellcheck = cfg.ui.spellCheck;
    };
  };
in
{
  options.programs.nixkraken.ui = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // profileOpts;
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
