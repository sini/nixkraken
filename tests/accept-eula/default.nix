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
  name = "accept-eula";

  nodes.machine = {
    imports = [
      ../_common
      ../_common/dummy-user.nix
    ];

    home-manager.users.root.programs.nixkraken = {
      enable = true;
      acceptEULA = true;
    };
  };

  enableOCR = true;
  testScript = lib.readFile ./test.py;

  meta = {
    maintainers = with lib.maintainers; [ nicolas-goudry ];
  };
}
