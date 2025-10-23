{ lib, ... }:

{
  autoPrune = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Automatically remove any remote-tracking references that no longer exist on the remote.
      <!-- scope: profile -->
    '';
  };

  defaultBranch = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    description = ''
      Set the default name when initializing a new repo.

      ::: info

      When not set, the app defaults to `main`.

      :::
      <!-- scope: profile -->
    '';
  };

  deleteOrigAfterMerge = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Automatically delete `.orig` files created by GitKraken client during a merge.
      <!-- scope: profile -->
    '';
  };

  detectConflicts = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable proactive detection of merge conflicts with target branch.
      <!-- scope: profile -->
    '';
  };

  fetchInterval = lib.mkOption {
    type = lib.types.ints.between 0 60;
    default = 1;
    description = ''
      Set the number of minutes between auto-fetches, or 0 to disable them.

      ::: info

      All visible remotes for the repository will be fetched.

      :::
      <!-- scope: profile -->
    '';
  };

  updateSubmodules = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Automatically keep submodules up to date when performing Git actions.
      <!-- scope: profile -->
    '';
  };

  useGitCredentialManager = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use the [Git credential manager](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage) to access Git repositories.
      <!-- scope: profile -->
    '';
  };
}
