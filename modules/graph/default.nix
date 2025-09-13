{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  profileOpts = import ./profile-options.nix args;

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
      options = appOpts // profileOpts;
    };
    default = { };
    description = ''
      Commit graph settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let
        columnAttrs = [
          "showAuthor"
          "showDatetime"
          "showMessage"
          "showRefs"
          "showSHA"
          "showGraph"
        ];
        columnSettings = lib.map (attr: cfg.graph.${attr}) columnAttrs;
        # Expect graph column settings to either be all null values (use defaults from app) or at least one is true
        # To account for the root-level versus profile-level usage, those values default to null so that when set at root-level
        # they don't get overridden by default values at profile-level
        allNull = builtins.all (setting: setting == null) columnSettings;
        oneTrue = lib.findFirst (setting: setting == true) false columnSettings;
      in
      [
        {
          assertion = allNull || oneTrue;
          message = "At least one graph column must be `true` or all columns must be `null` (${
            lib.concatStringsSep ", " (lib.map (col: "`graph.${col}`") columnAttrs)
          })";
        }
        {
          assertion = cfg.graph.showAll -> lib.isNull (cfg.graph.maxCommits);
          message = "Cannot set a maximum number of commits (`graph.maxCommits`) to show in commit graph if all commits are shown (`graph.showAll`)";
        }
      ];

    programs.nixkraken._submoduleSettings.graph = settings;
  };
}
