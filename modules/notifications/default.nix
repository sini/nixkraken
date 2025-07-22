{
  config,
  lib,
  localPkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;

  settings = {
    notification = {
      settings = {
        cloud = lib.optionalAttrs cfg.notifications.enable {
          inherit (cfg.notifications)
            feature
            help
            marketing
            system
            ;
        };

        local = {
          showDesktopNotifications = cfg.notifications.enable;
        };

        toastPosition = cfg.notifications.position;
      };
    };
  };
in
{
  options.programs.nixkraken.notifications = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      Notifications settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.activation.nixkraken-notifications-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      ${localPkgs.configure}/bin/gk-configure -c '${builtins.toJSON settings}'
    '';

    assertions = [
      {
        assertion =
          cfg.notifications.enable -> (with cfg.notifications; feature || help || marketing || system);
        message = "Notification topics cannot be enabled if notifications are disabled";
      }
    ];
  };
}
