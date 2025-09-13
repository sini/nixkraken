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
        columnAttrNames = [
          "showAuthor"
          "showDatetime"
          "showMessage"
          "showRefs"
          "showSHA"
          "showGraph"
        ];
      in
      [
        {
          assertion = lib.findFirst (setting: setting) false (
            lib.map (attr: cfg.graph.${attr}) columnAttrNames
          );
          message = "At least one graph column must be `true` (${
            lib.concatStringsSep ", " (lib.map (col: "`graph.${col}`") columnAttrNames)
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
