{
  config,
  lib,
  pkgs,
  ...
}:

{
  allowedSigners = lib.mkOption {
    type = with lib.types; nullOr path;
    default = null;
    description = ''
      File used for SSH signature verification.

      Unless [`gpg.format`](#gpgformat) is set to `ssh`, this will not have any effect.

      > [!NOTE]
      >
      > When unset, GitKraken will use the [global git configuration value](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile).
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

  package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = null;
    defaultText = lib.literalExpression ''
      if gpg.format == "openpgp" then pkgs.gnupg else pkgs.openssh
    '';
    description = ''
      Package to use for commit signing.

      When unset, the selected package defaults to:

      - [`pkgs.gnupg`](https://search.nixos.org/packages?show=gnupg&query=gnupg) when [`gpg.format`](#gpgformat) is set to `openpgp`
      - [`pkgs.openssh`](https://search.nixos.org/packages?show=openssh&query=openssh) when [`gpg.format`](#gpgformat) is set to `ssh`
    '';
  };

  program = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    example = "bin/ssh-keygen";
    description = ''
      Binary to use for commit signing.

      This is useful if the [`gpg.package`](#gpgpackage) exposes multiple programs and the one you wish
      to use for commit signing is not the default one.

      When unset, the selected program defaults to:

      - [`gpg.package`](#gpgpackage)'s main program when [`gpg.format`](#gpgformat) is set to `openpgp`
      - `bin/ssh-keygen` when [`gpg.format`](#gpgformat) is set to `ssh`

      > [!WARNING]
      >
      > Make sure that the selected program is exposed by the [`gpg.package`](#gpgpackage), since NixKraken
      > will not validate it.
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

      When [`gpg.format`](#gpgformat) is set to `openpgp`, this is the identifier of the GPG key used for signing.

      When [`gpg.format`](#gpgformat) is set to `ssh`, this is the path to the SSH private key used for signing.
    '';
  };
}
