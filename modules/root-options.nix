{ lib, ... }:

let
  gitkrakenVersions = import ../gitkraken/versions.nix;
  profileOpts = import ./profiles/options.nix { inherit lib; };
in
{
  enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to enable NixKraken.
      <!-- scope: global -->
    '';
  };

  acceptEULA = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Accept the [End User License Agreement](https://www.gitkraken.com/eula).
      <!-- scope: global -->
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

  defaultProfile = {
    icon = profileOpts.icon // {
      description = ''
        Icon avatar for the default profile.
        <!-- scope: profile -->
      '';
    };

    name = profileOpts.name // {
      default = "Default Profile";
      description = ''
        Name of the default profile.
        <!-- scope: profile -->
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
      <!-- scope: global -->
    '';
  };

  package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = null;
    example = "pkgs.unstable.gitkraken";
    description = ''
      The GitKraken package to use.

      ::: warning

      This option:

      - requires to allow unfree packages
      - is mutually exclusive with [`version`](#version)

      We advise users to use the [`version`](#version) option instead of this one, since we [cannot guarantee compatibility](../guide/notes/compatibility.md) when it is used.

      Also be aware that the [binary cache](../guide/user/caching.md) might not apply.

      :::
      <!-- scope: global -->
    '';
  };

  skipTutorial = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Skip the introduction tutorial.
      <!-- scope: global -->
    '';
  };

  version = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum (lib.attrNames gitkrakenVersions));
    default = lib.elemAt (lib.attrNames (
      lib.filterAttrs (version: spec: spec.latest or false) gitkrakenVersions
    )) 0;
    description = ''
      The GitKraken version to use.

      ::: warning

      When using this option, the GitKraken package will automatically be fetched from a commit of [nixpkgs](https://github.com/nixos/nixpkgs) known to be available in the cache. To benefit from the cache, users should first [configure it](../guide/user/caching.md).

      This option is mutually exclusive with [`package`](#package).

      :::
      <!-- scope: global -->
    '';
  };

  _submoduleSettings = lib.mkOption {
    internal = true;
    type = with lib.types; attrsOf (attrsOf anything);
    default = { };
  };
}
