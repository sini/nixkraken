{ lib, pkgs, ... }:

{
  package = lib.mkPackageOption pkgs "gnupg" {
    extraDescription = ''
      Used for GPG commit signing.
    '';
  };

  signingKey = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    example = "EC6624FA72B9487E";
    description = ''
      GPG private key to sign commits.
    '';
  };

  signCommits = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable GPG commit signature by default.
    '';
  };

  signTags = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable GPG tag signature by default.
    '';
  };
}
