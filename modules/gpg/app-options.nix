{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "gnupg" {
    extraDescription = ''
      <br/><br/>
      Used for commit signing.

      > [!WARNING]
      >
      > When using _ssh_ [`format`](#format), this **must** be changed from the default.
    '';
  };

  program = lib.mkOption {
    type = lib.types.str;
    default = "bin/${pkgs.gnupg.meta.mainProgram}";
    defaultText = "bin/${pkgs.gnupg.mainProgram}";
    example = "ssh-keygen";
    description = ''
      Binary from the [`package`](#package) to use.
    '';
  };
}
