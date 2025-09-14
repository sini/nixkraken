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
      UI theme.

      > [!NOTE]
      >
      > Extra themes are referenced by their `meta.name`, ie. `catppuccin-mocha`.
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
      > Zoom value is done in increment of 0.1 only. The value is truncated to a one decimal number.
      >
      > This means that setting this option to `0.96` will result in `0.9` being applied.
    '';
  };
}
