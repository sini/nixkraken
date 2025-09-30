# This test checks that a specific supported version of GitKraken can be installed.

_:

{
  home-manager.users.root.programs.nixkraken = {
    enable = true;
    version = "11.3.0";
  };
}
