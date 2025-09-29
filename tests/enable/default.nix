# This test checks that GitKraken is correctly installed and can be launched.
# It also tests that application and profile-specific configuration files gets written to home directory.

{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = pkgs.lib;
in
pkgs.testers.runNixOSTest {
  name = "enable";
  enableOCR = true;
  testScript = lib.readFile ./test.py;

  nodes.machine = {
    imports = [
      ../_common
    ];

    home-manager.users.root.programs.nixkraken.enable = true;
  };

  meta.maintainers = with lib.maintainers; [ nicolas-goudry ];
}
