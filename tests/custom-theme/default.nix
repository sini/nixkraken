# This test checks that GitKraken theme is correctly applied.
# It does so by checking that the rendered UI is mostly dark.

{ pkgs, ... }:

let
  # We can't use an overlay so we directly import the themes
  gitkraken-themes = pkgs.callPackage ../../themes { };
in

{
  machine = {
    home-manager.users.root = {
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

          ui = with gitkraken-themes; {
            extraThemes = [ catppuccin.mocha ];
            theme = catppuccin.mocha.id;
          };
        };
      };
    };
  };

  extraOpts = {
    extraPythonPackages =
      p: with p; [
        numpy
        pillow
      ];
  };
}
