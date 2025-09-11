# Enable display in tests
#
# Sources:
# - https://github.com/NixOS/nixpkgs/blob/f66c4ad65f0c573033851a0776cc27380d5c7271/nixos/tests/common/x11.nix
# - https://github.com/NixOS/nixpkgs/blob/f66c4ad65f0c573033851a0776cc27380d5c7271/nixos/tests/common/auto.nix

{ lib, ... }:

{
  # Enable X11
  services.xserver.enable = true;

  # Use IceWM as the window manager
  services.displayManager.defaultSession = "none+icewm";
  services.xserver.windowManager.icewm.enable = true;

  # Use lightdm as the desktop manager
  services.xserver.displayManager.lightdm.enable = true;

  # Help with OCR
  environment.etc."icewm/theme".text = ''
    Theme="gtk2/default.theme"
  '';

  # Automatically log in
  services.displayManager.autoLogin = {
    enable = true;
    user = "root";
  };

  # Allow auto login for root user with lightdm
  security.pam.services.lightdm-autologin.text = lib.mkForce ''
    auth     requisite pam_nologin.so
    auth     required  pam_succeed_if.so quiet
    auth     required  pam_permit.so

    account  include   lightdm

    password include   lightdm

    session  include   lightdm
  '';
}
