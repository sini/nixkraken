{ config, lib, ... }:

{
  signingKey = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.signing.key;
    defaultText = "config.programs.git.signing.key";
    example = "EC6624FA72B9487E";
    description = ''
      Private key to use for GPG signing.
    '';
  };

  signCommits = lib.mkOption {
    type = lib.types.bool;
    default = config.programs.git.signing.signByDefault;
    defaultText = "config.programs.git.signing.signByDefault";
    description = ''
      Enable GPG signature on commits.
    '';
  };

  signTags = lib.mkOption {
    type = lib.types.bool;
    default = config.programs.git.signing.signByDefault;
    defaultText = "config.programs.git.signing.signByDefault";
    description = ''
      Enable GPG signature on tags.
    '';
  };
}
