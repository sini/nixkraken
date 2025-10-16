{ lib, ... }:

{
  enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to enable desktop notifications.
      <!-- scope: global -->
    '';
  };

  feature = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Receive new features notifications.
      <!-- scope: global -->
    '';
  };

  help = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Receive help notifications.
      <!-- scope: global -->
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
      <!-- scope: global -->
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
      <!-- scope: global -->
    '';
  };

  system = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Receive system notifications.
      <!-- scope: global -->
    '';
  };
}
