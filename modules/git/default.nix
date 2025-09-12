{
  config,
  lib,
  pkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  commonOpts = import ./common-options.nix args;

  settings = {
    gitBinaryEnabled = !cfg.git.useBundledGit;
    keepGitConfigInSyncWithProfile = cfg.git.syncConfig;
  };
in
{
  options.programs.nixkraken.git = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // commonOpts;
    };
    default = { };
    description = ''
      Git settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!cfg.git.useBundledGit) [ cfg.git.package ];
    programs.nixkraken._submoduleSettings.git = settings;
  };
}
