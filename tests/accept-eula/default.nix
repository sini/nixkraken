# This test checks that EULA acceptance is working as intended.
# It also ensures that the tutorial can be skipped and that user info can be defined.

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
  enableOCR = true;
  testScript = lib.readFile ./test.py;

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

  meta.maintainers = with lib.maintainers; [ nicolas-goudry ];
}
