{ lib, ... }:

{
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

      Note: setting this to false may not work without a paid subscription.
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
    description = ''
      Receive system notifications.
    '';
  };
}
