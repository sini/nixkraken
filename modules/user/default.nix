{ config, lib, ... }@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;
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
    # Since the user submodule is shared by both top-level and profiles, we cannot rely on module type checks and
    # must instead resort to use an assertion on the resolved configuration data
    assertions =
      let
        allProfilesHaveUserAttr =
          attr: lib.foldl' (acc: { user }: acc && user.${attr} != null) true cfg.profiles;
      in
      [
        {
          assertion = cfg.user.email != null || allProfilesHaveUserAttr "email";
          message = "Either a default email (`user.email`) must be defined or all profiles must define a user email (`profile.user.email`)";
        }
        {
          assertion = cfg.user.name != null || allProfilesHaveUserAttr "name";
          message = "Either a default name (`user.name`) must be defined or all profiles must define a user name (`profile.user.name`)";
        }
      ];
  };
}
