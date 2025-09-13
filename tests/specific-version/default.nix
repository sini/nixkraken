# This test checks that a specific supported version of GitKraken can be installed.

{
  pkgs ? import <nixpkgs> {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "gitkraken"
      ];

    overlays = [ ];
  },
}:

let
  lib = pkgs.lib;
in
pkgs.testers.runNixOSTest {
  name = "specific-version";
  testScript = lib.readFile ./test.py;

  nodes.machine = {
    imports = [
      ../_common
    ];

    home-manager.users.root.programs.nixkraken = {
      enable = true;
      version = "11.3.0";
    };
  };

  meta.maintainers = with lib.maintainers; [ nicolas-goudry ];
}
