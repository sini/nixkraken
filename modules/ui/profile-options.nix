{ lib, ... }:

let
  cli = import ./cli-options.nix { inherit lib; };
  editor = import ./editor-options.nix { inherit lib; };
  launchpad = import ./launchpad-options.nix { inherit lib; };
in
{
  inherit cli editor launchpad;

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

  showRepoSummary = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Display WIP summary (for uncommitted changes on files like delete, add, edit, move) for repositories in Repository Management view.
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
      UI theme to use.

      > [!NOTE]
      >
      > Extra themes are referenced by their filename without extension.
      >
      > Refer to the [theming guide](@OPTIONS_ROOT@/../guides/theming.md) for further details.
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
    type = lib.types.numbers.between 0.8 1.3;
    default = 1;
    description = ''
      UI zoom percentage.

      > [!NOTE]
      >
      > GitKraken only supports zoom levels in 0.1 increments (0.8, 0.9, 1.0, etc.).
      >
      > Values are automatically rounded down to the nearest 0.1. For example, 0.96 becomes 0.9, and 1.23 becomes 1.2.
    '';
  };
}
