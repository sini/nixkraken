{ lib, ... }:

{
  syncConfig = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Automatically update the global Git configuration with the name and email address of the current profile.

      Note: if the global Git configuration is managed through Nix, this option will not have any effect.
    '';
  };

  useBundledGit = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use bundled [NodeGit](https://www.nodegit.org/) for Git actions.

      When this option is disabled, the `git` package must be installed. The module will try its best to set the right path to the `git` binary.

      Note: since some Git actions in GitKraken are not implemented using `git`, the bundled NodeGit will still be used for some actions, even if this option is disabled.
    '';
  };
}
