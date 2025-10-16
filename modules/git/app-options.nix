{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "git" {
    extraDescription = ''
      <br/>
      > [!NOTE]
      >
      > This is only used if [`git.useBundledGit`](#gitusebundledgit) is disabled.
      <!-- scope: global -->
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
      <!-- scope: global -->
    '';
  };

  useBundledGit = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      When this option is enabled, GitKraken will use the bundled [NodeGit](https://www.nodegit.org/) library.

      When this option is disabled, GitKraken will use the [`git.package`](#gitpackage) option to install Git and set it as the selected Git binary used for certain Git actions including fetching and committing. This may provide increased performance and compatibility with certain projects and development environments.
      <!-- scope: global -->
    '';
  };
}
