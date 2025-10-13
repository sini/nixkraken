# This test checks that GitKraken is correctly installed and can be launched.
# It also tests that application and profile-specific configuration files gets written to home directory.

_:

{
  imports = [
    ../_common/base-config.nix
  ];

  home-manager.users.root.programs.nixkraken.defaultProfile.name = "NixKraken rocks";
}
