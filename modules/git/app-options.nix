{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "git" {
    extraDescription = ''
      <br/><br/>
      > [!NOTE]
      >
      > This is only used if [`git.useBundledGit`](#gitusebundledgit) is disabled.
    '';
  };

  syncConfig = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Automatically update the global Git configuration with the name and email address of the current profile.

      > [!NOTE]
      >
      > If the global Git configuration is managed through Nix, this option will not have any effect.
    '';
  };

  useBundledGit = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      When this option is enabled, GitKraken will use the bundled [NodeGit](https://www.nodegit.org/) library.

      When this option is disabled, GitKraken will use the `git` package instead of the NodeGit library for certain Git actions including fetching and committing. This may provide increased performance and compatibility with certain projects and development environments.

      If disabled, the [`git.package`](#gitpackage) option is used to install Git and set it as the selected Git binary used by GitKraken.
    '';
  };
}
