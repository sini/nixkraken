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
      in
      (builtins.foldl' (
        warnings: profile:
        if
          (cast profile.gpg.signCommits || cast profile.gpg.signTags) && profile.gpg.signingKey == null
        then
          warnings
          ++ [
            "Profile \"${profile.name}\" has commit/tag signing enabled, but no signing key was defined."
          ]
        else
          warnings
      ) [ ] cfg.profiles)
      ++ lib.optional (
        (cast cfg.gpg.signCommits || cast cfg.gpg.signTags) && cfg.gpg.signingKey == null
      ) "GPG commit/tag signature is enabled but no signing key was defined.";

    home.packages = [ cfg.gpg.package ];
  };
}
