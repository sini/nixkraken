{
  config,
  lib,
  pkgs,
  ...
}:

{
  allowedSigners = lib.mkOption {
    type = with lib.types; nullOr (either str path);
    default = null;
    description = ''
      File used for SSH signature verification.

      > [!WARNING]
      >
      > This option can only be defined if [`format`](#gpgformat) is set to `ssh`.

      > [!NOTE]
      >
      > When `null`, the global git configuration value is used.
    '';
  };

  format = lib.mkOption {
    type = lib.types.enum [
      "openpgp"
      "ssh"
    ];
    default = "openpgp";
    description = ''
      Format to use for commit signing.
    '';
  };

  package = lib.mkPackageOption pkgs "gnupg" {
    extraDescription = ''
      <br/><br/>
      Used for commit signing.

      > [!WARNING]
      >
      > When using _ssh_ [`format`](#gpgformat), this **must** be changed from the default.
    '';
  };

  program = lib.mkOption {
    type = lib.types.str;
    default = "bin/${pkgs.gnupg.meta.mainProgram}";
    defaultText = "bin/\${pkgs.gnupg.mainProgram}";
    example = "ssh-keygen";
    description = ''
      Binary from the [`package`](#gpgpackage) to use.
    '';
  };

  signCommits = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = config.programs.git.signing.signByDefault;
    defaultText = "config.programs.git.signing.signByDefault";
    description = ''
      Enable commit signature.
    '';
  };

  signTags = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = config.programs.git.signing.signByDefault;
    defaultText = "config.programs.git.signing.signByDefault";
    description = ''
      Enable tag signature.
    '';
  };

  signingKey = lib.mkOption {
    type = with lib.types; nullOr (either str path);
    default = config.programs.git.signing.key;
    defaultText = "config.programs.git.signing.key";
    example = "EC6624FA72B9487E";
    description = ''
      Private key to use for commit signing.

      When using _openpgp_ [`format`](#gpgformat), this is the identifier of the GPG key used for signing.

      When using _ssh_ [`format`](#gpgformat), this is the path to the SSH private key used for signing.
    '';
  };
}
