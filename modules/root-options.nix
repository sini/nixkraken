{ lib, ... }:

let
  gitkrakenVersions = lib.attrNames (import ../gitkraken/versions.nix);
  profileOpts = import ./profiles/options.nix { inherit lib; };
in
{
  enable = lib.mkEnableOption "GitKraken";

  acceptEULA = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Accept the [End User License Agreement](https://www.gitkraken.com/eula).
    '';
  };

  # enableCloudPatch = lib.mkOption {
  #   type = lib.types.bool;
  #   default = false;
  #   description = ''
  #     Enable [Cloud Patches](https://www.gitkraken.com/solutions/cloud-patches).
  #
  #     Note: Cloud Patches ToS will be automatically accepted when enabled.
  #   '';
  # };

  # TODO: remove once ui.launchpad.collapsed exists
  # collapsePermanentTabs = lib.mkOption {
  #   type = lib.types.bool;
  #   default = false;
  #   description = ''
  #     Force collapse permanent tabs (Focus and Worspace views).
  #   '';
  # };

  defaultProfile = {
    icon = profileOpts.icon // {
      description = ''
        Icon avatar for the default profile.
      '';
    };

    name = profileOpts.name // {
      default = "Default Profile";
      description = ''
        Name of the default profile.
      '';
    };
  };

  logLevel = lib.mkOption {
    type = lib.types.enum [
      "standard"
      "extended"
      "silly"
    ];
    default = "standard";
    description = ''
      Set log level in activity log.
    '';
  };

  package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = null;
    example = "pkgs.unstable.gitkraken";
    description = ''
      The GitKraken package to use.

      > [!IMPORTANT]
      >
      > This option:
      >
      > - requires to allow unfree packages
      > - is mutually exclusive with [`version`](#version)

      > [!NOTE]
      >
      > We advise users to use the [`version`](#version) option instead of this one, since we [cannot guarantee compatibility](../getting-started/install/considerations.html#compatibility) when it is used.
      >
      > Also be aware that the [binary cache](../getting-started/caching.html) might not apply.
    '';
  };

  skipTutorial = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Skip the introduction tutorial.
    '';
  };

  version = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum gitkrakenVersions);
    default = "11.4.0";
    description = ''
      The GitKraken version to use. Requires to allow unfree packages.

      > [!IMPORTANT]
      >
      > This option:
      >
      > - requires to allow unfree packages
      > - is mutually exclusive with [`package`](#package)
    '';
  };

  _submoduleSettings = lib.mkOption {
    internal = true;
    type = with lib.types; attrsOf (attrsOf anything);
    default = { };
  };
}
