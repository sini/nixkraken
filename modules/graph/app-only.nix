{ config, lib, ... }:

let
  cfg = config.programs.nixkraken;

  settings = {
    commits = {
      inherit (cfg.commitGraph) showAll;

      enableCommitsLazyLoading = cfg.commitGraph.lazy;
      maxCommitsInGraph = cfg.commitGraph.max;
    };
  };
in
{
  options.programs.nixkraken = {
    commitGraph = lib.mkOption {
      type = lib.types.submodule {
        options = {
          lazy = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Enable commits lazy loading.
              Additional commits will be loaded if the earliest commit in the graph is reached.
            '';
          };

          max = lib.mkOption {
            type = with lib.types; addCheck ints.positive (x: x >= 500);
            default = 2000;
            description = ''
              Maximum number of commits to show in the commit graph.
              Lower counts may help improve performance.
              Minimum value is 500.
            '';
          };

          showAll = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Always show all commits in repository.
              This setting may cause performance issue with large repositories.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.nixkraken-graph-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
    '';
  };
}
