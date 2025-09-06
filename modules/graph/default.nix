{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  commonOpts = import ./common-options.nix args;

  settings = {
    commits = {
      inherit (cfg.commitGraph) showAll;

      enableCommitsLazyLoading = cfg.commitGraph.lazy;
      maxCommitsInGraph = cfg.commitGraph.max;
    };
  };
in
{
  options.programs.nixkraken.commitGraph = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // commonOpts;
    };
    default = { };
    description = ''
      Commit graph settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.commitGraph.showAuthor
          || cfg.commitGraph.showDatetime
          || cfg.commitGraph.showMessage
          || cfg.commitGraph.showRefs
          || cfg.commitGraph.showSha
          || cfg.commitGraph.showTree;
        message = "Commit graph cannot be empty";
      }
    ];

    programs.nixkraken._submoduleSettings.graph = settings;
  };
}
