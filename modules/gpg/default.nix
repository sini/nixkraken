{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  profileOpts = import ./profile-options.nix args;
in
{
  options.programs.nixkraken.gpg = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // profileOpts;
    };
    default = { };
    description = ''
      GPG settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.git.useBundledGit
          -> (builtins.all (attrset: attrset.gpg.format != "ssh") (cfg.profiles ++ [ cfg ]));
        message = "SSH signing (`gpg.format` = \"ssh\") is only supported with Git executable (`git.useBundledGit = false`).";
      }
    ];

    warnings =
      let
        cast = value: value != null && value;
        hasSigningWithoutKey =
          attrset:
          (cast attrset.gpg.signCommits || cast attrset.gpg.signTags) && attrset.gpg.signingKey == null;
      in
      (builtins.foldl' (
        warnings: profile:
        warnings
        ++ (lib.optionals (hasSigningWithoutKey profile) [
          "Profile \"${profile.name}\" has commit/tag signing (`gpg.signCommits`, `gpg.signTags`) enabled, but no signing key (`gpg.signingKey`) was defined."
        ])
      ) [ ] cfg.profiles)
      ++ lib.optional (hasSigningWithoutKey cfg) "Commit/tag signature (`gpg.signCommits`, `gpg.signTags`) is enabled but no signing key (`gpg.signingKey`) was defined."

    home.packages = [ cfg.gpg.package ];
  };
}
