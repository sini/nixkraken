{ lib, ... }:

{
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
}
