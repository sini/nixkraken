{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "gnupg" {
    extraDescription = ''
      <br/><br/>
      Used for GPG signing.
    '';
  };
}
