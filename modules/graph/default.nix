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
      lib.flatten (
        lib.map (
          attrset:
          let
            profileName = attrset.name or attrset.defaultProfile.name;
          in
          [
            {
              assertion = lib.findFirst (setting: setting) false (
                lib.map (column: lib.getAttr column attrset.graph) columnAttrNames
              );
              message = "[${profileName}] At least one graph column must be `true` (${
                lib.concatStringsSep ", " (lib.map (col: "`graph.${col}`") columnAttrNames)
              })";
            }
          ]
        ) (cfg.profiles ++ [ cfg ])
      )
      ++ [
        {
          assertion = cfg.graph.showAll -> cfg.graph.maxCommits == null;
          message = "`graph.maxCommits` cannot be set if `graph.showAll` is enabled";
        }
      ];

    programs.nixkraken._submoduleSettings.graph = settings;
  };
}
