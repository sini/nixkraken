# This test checks that a custom datetime format can be configured and is displayed as expected in the UI.
# It also ensures that Git configuration is inherited from Home Manager settings and that graph columns customization is working.

{ jq, ... }:

{
  imports = [
    ../_common/base-config.nix
  ];

  environment.systemPackages = [
    jq
  ];

  home-manager.users.root = {
    home.file."repoTab.json" = {
      source = ./repoTab.json;
    };

    programs.nixkraken = {
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
}
