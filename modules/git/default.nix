{
  config,
  lib,
  localPkgs,
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
    home.activation.nixkraken-git-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      ${localPkgs.configure}/bin/gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
    '';
  };
}
