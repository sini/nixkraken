{ config, lib, ... }:

let
  cfg = config.programs.gitkraken;

  settings = {
    gitBinaryEnabled = !cfg.git.useBundledGit;
    keepGitConfigInSyncWithProfile = cfg.git.syncConfig;
  };
in
{
  options = {
    git = lib.mkOption {
      type = lib.types.submodule {
        options = {
          syncConfig = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Automatically update the global Git configuration with the name and email address
              of the current profile.
            '';
          };

          useBundledGit = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Use bundled NodeGit for Git actions.
              When this option is set to `false`, the Git package must be installed.
              The module will try its best to set the right path to the Git binary.
              Note: not all Git actions are implemented through Git executable, so the bundled
              NodeGit will still be used for some actions, even if disabled.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    activation.nixkraken-git-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
    '';
  };
}
