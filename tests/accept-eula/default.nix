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
    ];

    home-manager.users.root.programs.nixkraken = {
      enable = true;
      acceptEULA = true;

      # In order to check for EULA acceptance, we have to skip tutorial
      skipTutorial = true;

      # Because we skip tutorial, we have to set user info
      user = {
        email = "somebody@example.com";
        name = "Somebody";
      };
    };
  };

  enableOCR = true;
  testScript = lib.readFile ./test.py;

  meta = {
    maintainers = with lib.maintainers; [ nicolas-goudry ];
  };
}
