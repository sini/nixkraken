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

      > [!WARNING]
      >
      > Disabling this option without a paid subscription will have no effect.
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
