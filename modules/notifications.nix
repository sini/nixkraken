{ config, lib, ... }:

let
  cfg = config.programs.nixkraken;

  settings = {
    notification = {
      settings = {
        cloud = lib.optional cfg.notifications.enable {
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
  options.programs.nixkraken = {
    notifications = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "desktop notifications";

          feature = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Receive new features notifications.
            '';
          };

          help = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Receive help notifications.
            '';
          };

          marketing = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Receive marketing notifications.
              Setting it to false may not work without a paid subscription.
            '';
          };

          position = lib.mkOption {
            type = lib.types.enum [
              "top-left"
              "top-right"
              "bottom-left"
              "bottom-right"
            ];
            default = "bottom-left";
            description = ''
              Notification location within window.
            '';
          };

          system = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
        };
      };
      default = { };
      description = ''
        Notifications settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.nixkraken-notifications-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
    '';
  };
}
