{ lib, ... }:

{
  options.programs.nixkraken.git = lib.mkOption {
    type = lib.types.submodule {
      options = {
        autoFetchInterval = lib.mkOption {
          type = lib.types.ints.between 0 60;
          default = 1;
          description = ''
            Set the number of minutes between auto-fetches.
            It will fetch all visible remotes for the repository.
            Setting the value to 0 will disable auto-fetch.
          '';
        };

        autoPrune = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Automatically remove any remote-tracking references that no longer exist on the
            remote.
          '';
        };

        autoUpdateSubmodules = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Automatically keep submodules up to date when performing Git actions.
          '';
        };

        defaultBranch = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Set the default name when initializing a new repo. The app defaults to `main`.
          '';
        };
      };
    };
    default = { };
    description = ''
      Git settings.
    '';
  };
}
