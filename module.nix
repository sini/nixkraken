{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixkraken;

  localPkgs = pkgs.lib.packagesFromDirectoryRecursive {
    directory = ./pkgs;
    callPackage = pkgs.callPackage;
  };
  gitkraken = import ./gitkraken pkgs;
  gitkrakenVersions = lib.attrNames (import ./gitkraken/versions.nix);

  # TODO: where to find them
  logLevels = {
    standard = 1;
    extended = 2;
    silly = 3;
  };

  # curl -fsSLH "Authorization: Bearer $(gk-decrypt $HOME/.gitkraken/secFile | jq -r '.GitKraken."api-accessToken"')" https://api.gitkraken.com/user | jq -r '.eulaVersion'
  eulaVersion = "8.3.1";

  settings = {
    activityLogLevel = logLevels.${cfg.logLevel};
    # cloudPatchesEnabled = cfg.enableCloudPatch;
    # cloudPatchTermsAccepted = cfg.enableCloudPatch;

    registration = lib.optionalAttrs cfg.acceptEULA {
      EULA = {
        status = "agree_verified";
        version = eulaVersion;
      };
    };

    tutorial = {
      isLifecycleAlreadyTriggeredByTutorialKey = {
        INTRO_TUTORIAL = {
          TUTORIAL_OPENED = cfg.skipTutorial;
          TUTORIAL_COMPLETED = cfg.skipTutorial;
          TUTORIAL_CLOSED = cfg.skipTutorial;
        };
      };
    };

    userMilestones = {
      completedNewUserOnboarding = true;
      firstAppOpen = true;
      firstProfileCreated = true;
      introTutorialWelcomeStepSkipped = true;
    }
    // lib.optionalAttrs cfg.skipTutorial {
      createACommit = true;
      firstRepoOpened = true;
      firstTimeCommitSelected = true;
      leftPanelToggled = true;
      makeABranch = true;
      mergeABranch = true;
    };
  }
  // (lib.mergeAttrsList (lib.attrValues cfg._submoduleSettings));

  # `pkgs` is not passed down to modules imported from root module using `imports`, hence this function returns a lambda
  # with original arguments merged with `pkgs` attribute from the root module.
  mkSubmoduleWithPkgs =
    submodulePath: args:
    let
      submodule = import submodulePath (args // { inherit localPkgs pkgs; });
    in
    submodule;
in
{
  meta.maintainers = with lib.maintainers; [ nicolas-goudry ];

  imports = [
    (mkSubmoduleWithPkgs ./modules/datetime)
    (mkSubmoduleWithPkgs ./modules/git)
    (mkSubmoduleWithPkgs ./modules/gpg)
    (mkSubmoduleWithPkgs ./modules/graph)
    (mkSubmoduleWithPkgs ./modules/notifications)
    (mkSubmoduleWithPkgs ./modules/profile)
    (mkSubmoduleWithPkgs ./modules/ssh)
    (mkSubmoduleWithPkgs ./modules/tools)
    (mkSubmoduleWithPkgs ./modules/ui)
    (mkSubmoduleWithPkgs ./modules/user)
  ];

  options.programs.nixkraken = {
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
        The GitKraken package to use. Requires to allow unfree packages.

        **Only one of [`package`](#package) or [`version`](#version) must be set.**

        Note: we advise users to use the [`version`](#version) option instead of this one, since we [cannot guarantee compatibility](../getting-started/install/considerations.html#compatibility) when this option is used. Also be aware that the [binary cache](../getting-started/caching.html) might not apply.
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

        **Only one of [`package`](#package) or [`version`](#version) must be set.**
      '';
    };

    _submoduleSettings = lib.mkOption {
      internal = true;
      type = with lib.types; attrsOf (attrsOf anything);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package == null -> cfg.version != null;
        message = "Either one of GitKraken version (`version`) or GitKraken package (`package`) must be set";
      }
      {
        assertion = cfg.package != null -> cfg.version == null;
        message = "GitKraken version (`version`) and GitKraken package (`package`) cannot be set at the same time";
      }
    ];

    home = {
      packages = [
        (
          if cfg.package != null then
            cfg.package
          else
            gitkraken.${lib.replaceStrings [ "." ] [ "-" ] cfg.version}
        )
        localPkgs.login
      ];

      # Activating has side effects and must therefore be placed after the write boundary
      activation.nixkraken-top-level = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${localPkgs.configure}/bin/gk-configure -c '${builtins.toJSON settings}'
        ${lib.optionalString (
          lib.length cfg.ui.extraThemes > 0
        ) "${localPkgs.theme}/bin/gk-theme -i '${lib.concatStringsSep "," cfg.ui.extraThemes}'"}
        echo "To login to your GitKraken account, run 'gk-login'."
      '';
    };
  };
}
