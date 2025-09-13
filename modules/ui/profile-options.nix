{ lib, ... }:

let
  cli = import ./cli-options.nix { inherit lib; };
  editor = import ./editor-options.nix { inherit lib; };
in
{
  inherit cli editor;

  rememberTabs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Remember open tabs when exiting.
    '';
  };

  showLeftPanel = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show left panel showing remotes, worktrees, stashes, …
    '';
  };

  sortOrder = lib.mkOption {
    type = lib.types.enum [
      "ascending"
      "descending"
    ];
    default = "ascending";
    description = ''
      Sort files in right panel alphabetically.
    '';
  };

  treeView = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Display files in tree view mode in right panel.
    '';
  };

  zoom = lib.mkOption {
    type = lib.types.enum [
      0.8
      0.9
      1
      1.1
      1.2
      1.3
    ];
    default = 1;
    description = ''
      UI zoom percentage.
    '';
  };

  theme = lib.mkOption {
    type =
      with lib.types;
      nullOr (
        either str (enum [
          "light"
          "light-high-contrast"
          "dark"
          "dark-high-contrast"
          "system"
        ])
      );
    default = "system";
    example = "dark";
    description = ''
      UI theme.

      > [!NOTE]
      >
      > Extra themes are referenced by their `meta.name`, ie. `catppuccin-mocha`.
    '';
  };
}
