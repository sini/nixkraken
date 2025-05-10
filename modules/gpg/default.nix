{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;
in
{
  options.programs.nixkraken.gpg = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
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
