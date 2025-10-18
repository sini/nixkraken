{ config, lib, ... }@args:

let
  cfg = config.programs.nixkraken;
  options = import ./profile-options.nix args;
in
{
  options.programs.nixkraken.user = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      User settings.
    '';
  };

  config = lib.mkIf (cfg.enable) {
    assertions = [
      {
        assertion = cfg.skipTutorial -> cfg.user.email != null;
        message = "When tutorial is skipped, a default email (`user.email`) must be defined";
      }
      {
        assertion = cfg.skipTutorial -> cfg.user.name != null;
        message = "When tutorial is skipped, a default name (`user.name`) must be defined";
      }
    ];
  };
}
