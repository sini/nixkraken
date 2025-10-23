{ lib, ... }:

{
  lazy = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable commits lazy loading.

      ::: info

      Additional commits will be loaded when reaching the earliest commit in the graph.

      :::
      <!-- scope: global -->
    '';
  };

  maxCommits = lib.mkOption {
    type = with lib.types; nullOr (addCheck ints.positive (x: x >= 500));
    default = 2000;
    description = ''
      Maximum number of commits to show in the commit graph. **Minimum value is 500.**

      ::: info

      Lower counts may help improve performance.

      :::
      <!-- scope: global -->
    '';
  };

  showAll = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Always show all commits in repository.

      ::: warning

      This setting may cause performance issue with large repositories (like nixpkgs).

      :::
      <!-- scope: global -->
    '';
  };
}
