{ lib, ... }:

{
  lazy = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable commits lazy loading.

      Note: additional commits will be loaded when reaching the earliest commit in the graph.
    '';
  };

  maxCommits = lib.mkOption {
    type = with lib.types; nullOr (addCheck ints.positive (x: x >= 500));
    default = 2000;
    description = ''
      Maximum number of commits to show in the commit graph. **Minimum value is 500.**

      Note: lower counts may help improve performance.
    '';
  };

  showAll = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Always show all commits in repository.

      Note: this setting may cause performance issue with large repositories (like nixpkgs).
    '';
  };
}
