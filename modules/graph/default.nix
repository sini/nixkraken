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
      inherit (cfg.graph) showAll;

      enableCommitsLazyLoading = cfg.graph.lazy;
      maxCommitsInGraph = cfg.graph.maxCommits;
    };
  };
in
{
  options.programs.nixkraken.graph = lib.mkOption {
    type = lib.types.submodule {
      options = appOpts // commonOpts;
    };
    default = { };
    description = ''
      Commit graph settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let
        columnSettings = [
          cfg.graph.showAuthor
          cfg.graph.showDatetime
          cfg.graph.showMessage
          cfg.graph.showRefs
          cfg.graph.showSHA
          cfg.graph.showGraph
        ];
        allNull = builtins.all (setting: setting == null) columnSettings;
        oneTrue = lib.findFirst (setting: setting == true) false columnSettings;
      in
      [
        {
          assertion = allNull || oneTrue;
          message = "Commit graph cannot be empty (`graph.*`)";
        }
        {
          assertion = cfg.graph.showAll -> lib.isNull (cfg.graph.maxCommits);
          message = "Cannot set a maximum number of commits (`graph.maxCommits`) to show in commit graph if all commits are shown (`graph.showAll`)";
        }
      ];

    programs.nixkraken._submoduleSettings.graph = settings;
  };
}
