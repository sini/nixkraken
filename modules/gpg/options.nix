{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "gnupg" {
    extraDescription = ''
      <br/><br/>
      Used for GPG signing.
    '';
  };

  signingKey = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    example = "EC6624FA72B9487E";
    description = ''
      Private key to use for GPG signing.
    '';
  };

  signCommits = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable GPG signature on commits.
    '';
  };

  signTags = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable GPG signature on tags.
    '';
  };
}
