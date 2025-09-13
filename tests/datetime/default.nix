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
  name = "datetime";

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [
        ../_common
      ];

      environment.systemPackages = with pkgs; [
        jq
      ];

      home-manager.users.root = {
        home.file."repoTab.json" = {
          source = ./repoTab.json;
        };

        programs = {
          git = {
            enable = true;
            userEmail = "somebody@example.com";
            userName = "Somebody";
          };

          nixkraken = {
            enable = true;
            acceptEULA = true;
            skipTutorial = true;

            datetime = {
              format = "\\c\\u\\s\\t\\o\\m \\t\\i\\m\\e";
            };

            # Only display commit datetime in graph
            graph = {
              showAuthor = false;
              showDatetime = true;
              showMessage = false;
              showRefs = false;
              showSHA = false;
              showGraph = false;
            };
          };
        };
      };
    };

  enableOCR = true;
  testScript = lib.readFile ./test.py;

  meta = {
    maintainers = with lib.maintainers; [ nicolas-goudry ];
  };
}
