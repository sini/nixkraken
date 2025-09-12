{ lib, ... }:

{
  autoFetchInterval = lib.mkOption {
    type = lib.types.ints.between 0 60;
    default = 1;
    description = ''
      Set the number of minutes between auto-fetches, or 0 to disable them.

      Note: all visible remotes for the repository will be fetched.
    '';
  };

  autoPrune = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Automatically remove any remote-tracking references that no longer exist on the remote.
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
      Set the default name when initializing a new repo.

      Note: when not set, the app defaults to `main`.
    '';
  };

  deleteOrigAfterMerge = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Automatically delete `.orig` files created by GitKraken client during a merge.
    '';
  };
}
