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

  nodes.machine = {
    imports = [
      ../_common
    ];

    home-manager.users.root.programs.nixkraken = {
      enable = true;
      version = lib.mkForce "11.3.0";
    };
  };

  testScript = lib.readFile ./test.py;

  meta = {
    maintainers = with lib.maintainers; [ nicolas-goudry ];
  };
}
