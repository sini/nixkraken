{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixkraken;
in
{
  options.programs.nixkraken.gpg = lib.mkOption {
    type = lib.types.submodule {
      options = {
        package = lib.mkPackageOption pkgs "gnupg" { } // {
          description = ''
            Which program to use for GPG commit signing.
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
      };
    };
    default = { };
    description = ''
      GPG settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    warnings =
      (builtins.foldl' (
        warnings: profile:
        if
          (profile.gpg.signCommits || profile.gpg.signTags)
          && (profile.gpg.signingKey == null)
          && (cfg.gpg.signingKey == null)
        then
          warnings
          ++ [
            "Profile ${profile.id} has GPG commit/tag signature enabled, but no signing key was defined in the profile nor globally."
          ]
        else
          warnings
      ) [ ] cfg.profiles)
      ++ lib.optionals ((cfg.gpg.signCommits || cfg.gpg.signTags) && (cfg.gpg.signingKey == null)) [
        "GPG commit/tag signature is enabled but no signing key was defined."
      ];
  };
}
