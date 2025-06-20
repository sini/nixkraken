{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixkraken;

  nixpkgsCommit = "37290199a6648a1e501839e07f6f9be95e4c58cc";
  nixpkgs = pkgs.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = nixpkgsCommit;
    hash = "sha256-MiJ11L7w18S2G5ftcoYtcrrS0JFqBaj9d5rwJFpC5Wk=";
  };
  gitkraken =
    (import nixpkgs {
      system = pkgs.system;
      config.allowUnfree = true;
    }).gitkraken;

  localPkgs = import ./pkgs {
    inherit (pkgs) lib;
    inherit pkgs;
  };

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
    cloudPatchesEnabled = cfg.enableCloudPatch;
    cloudPatchTermsAccepted = cfg.enableCloudPatch;
    onboardingGuideDismissed = cfg.skipTour;

    ui = {
      spellcheck = cfg.spellCheck;
    };

    userMilestones =
      {
        firstAppOpen = true;
        firstProfileCreated = true;
        completedNewUserOnboarding = true;
      }
      // lib.optionalAttrs cfg.skipTour {
        firstAppOpen = true;
        firstRepoOpened = true;
        guideOpened = true;
        startATrial = true;
        connectIntegration = true;
        makeABranch = true;
        createACommit = true;
        pushSomeCode = true;
        createAWorkspace = true;
        createASharedDraft = true;
      };

    registration = lib.optionalAttrs cfg.acceptEULA {
      EULA = {
        status = "agree_unverified";
        version = eulaVersion;
      };
    };
  };

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

    enableCloudPatch = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable [Cloud Patches](https://www.gitkraken.com/solutions/cloud-patches).

        Note: Cloud Patches ToS will be automatically accepted when enabled.
      '';
    };

    # Default from app config but can be overridden by profiles
    collapsePermanentTabs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Force collapse permanent tabs (Focus and Worspace views).
      '';
    };

    # Default from app config but can be overridden by profiles
    deleteOrigAfterMerge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Automatically delete `.orig` files created by GitKraken client during a merge.
      '';
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
      type = lib.types.package;
      default = gitkraken;
      defaultText = "pkgs.gitkraken";
      example = "pkgs.unstable.gitkraken";
      description = ''
        The GitKraken package to use. Requires to allow unfree packages.

        Note: Nixkraken automatically installs the correct GitKraken version which has been tested with the module. End users should refrain using this option, and if they do they should be aware that [compatibility is not guaranteed](/guide/install/considerations.html#compatibility).

        Current default uses the GitKraken package from nixpkgs commit [${nixpkgsCommit}](https://github.com/nixos/nixpkgs/blob/${nixpkgsCommit}/pkgs/by-name/gi/gitkraken/package.nix).
      '';
    };

    # Default from app config but can be overridden by profiles
    rememberTabs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Remember open tabs when exiting.
      '';
    };

    skipTour = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Skip the onboarding guide.
      '';
    };

    spellCheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable spell checking.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
        localPkgs.login
      ];

      # Activating has side effects and must therefore be placed after the write boundary
      activation.nixkraken-top-level = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${localPkgs.configure}/bin/gk-configure -c '${builtins.toJSON settings}'
        echo "To login to your GitKraken account, run 'gk-login'."
      '';
    };
  };
}
