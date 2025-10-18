{
  config,
  lib,
  pkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./profile-options.nix args;
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
        validPkgsWithFormat = {
          gpg = [
            "gnupg"
            "gnupg1compat"
          ];
          ssh = [
            "openssh"
            "openssh-with-hpn"
            "openssh-test"
            "openssh-with-gssapi"
          ];
        };
        hasPkgIncompatibleWithFormat =
          attrset:
          # Only check for compatibility with format if package is explicitly set
          # When unset, it defaults to either gnupg or openssh, depending on format
          # See home.packages
          if attrset.gpg.package != null then
            (attrset.gpg.format == "ssh" && lib.elem attrset.gpg.package.pname validPkgsWithFormat.gpg)
            || (attrset.gpg.format == "openpgp" && lib.elem attrset.gpg.package.pname validPkgsWithFormat.ssh)
          else
            false;
      in
      (builtins.foldl' (
        warnings: profile:
        warnings
        ++ (lib.optionals (hasSigningWithoutKey profile) [
          "Profile \"${profile.name}\" has commit/tag signing (`gpg.signCommits`, `gpg.signTags`) enabled, but no signing key (`gpg.signingKey`) was defined."
        ])
        ++ (lib.optionals (hasPkgIncompatibleWithFormat profile) [
          "Profile \"${profile.name}\" is potentially using an incompatible commit signing package (`gpg.package` => ${cfg.gpg.package.name}) for the selected commit signing format (`gpg.format` => ${cfg.gpg.format})."
        ])
      ) [ ] cfg.profiles)
      ++ lib.optional (hasSigningWithoutKey cfg) "Commit/tag signature (`gpg.signCommits`, `gpg.signTags`) is enabled but no signing key (`gpg.signingKey`) was defined."
      ++ lib.optional (hasPkgIncompatibleWithFormat cfg) "Selected commit signing package (`gpg.package` => ${cfg.gpg.package.name}) may be incompatible with commit signing format (`gpg.format` => ${cfg.gpg.format})";

    home.packages = lib.unique (
      lib.map (
        conf:
        if conf.gpg.package == null then
          (if conf.gpg.format == "openpgp" then pkgs.gnupg else pkgs.openssh)
        else
          conf.gpg.package
      ) (cfg.profiles ++ [ { inherit (cfg) gpg; } ])
    );
  };
}
