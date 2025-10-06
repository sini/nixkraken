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
  gitkraken = pkgs.callPackage ./gitkraken { };

  # TODO: where to find them
  logLevels = {
    standard = 1;
    extended = 2;
    silly = 3;
  };

  # TODO: replace by test
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

    userMilestones = lib.optionalAttrs cfg.skipTutorial {
      completedNewUserOnboarding = true;
      firstAppOpen = true;
      firstProfileCreated = true;
      introTutorialWelcomeStepSkipped = true;
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
  options.programs.nixkraken = import ./modules/root-options.nix { inherit lib; };

  imports = [
    (mkSubmoduleWithPkgs ./modules/datetime)
    (mkSubmoduleWithPkgs ./modules/git)
    (mkSubmoduleWithPkgs ./modules/gpg)
    (mkSubmoduleWithPkgs ./modules/graph)
    (mkSubmoduleWithPkgs ./modules/notifications)
    (mkSubmoduleWithPkgs ./modules/profiles)
    (mkSubmoduleWithPkgs ./modules/ssh)
    (mkSubmoduleWithPkgs ./modules/tools)
    (mkSubmoduleWithPkgs ./modules/ui)
    (mkSubmoduleWithPkgs ./modules/user)
  ];

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
        (if cfg.package != null then cfg.package else gitkraken.override { inherit (cfg) version; })
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
