{
  config,
  lib,
  localPkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;
  profileBuilder = import ./utils/profile-builder.nix { inherit cfg lib; };

  # Build default profile using same attributes as additional profiles, with values coming from top-level modules
  defaultProfile =
    let
      topLevelOpts = lib.listToAttrs (
        lib.map (opt: lib.nameValuePair opt cfg.${opt}) (
          lib.filter (attr: attr != "icon" && attr != "isDefault" && attr != "name") (lib.attrNames options)
        )
      );
    in
    {
      isDefault = true;
      name = cfg.defaultProfile.name;
      icon = cfg.defaultProfile.icon;
    }
    // topLevelOpts;

  profiles = lib.attrsets.mergeAttrsList (
    lib.map profileBuilder (
      [ defaultProfile ]
      # Additional profiles inherit options from default profile
      ++ (lib.map (profile: lib.recursiveUpdate defaultProfile profile) cfg.profiles)
    )
  );
in
{
  options.programs.nixkraken.profiles = lib.mkOption {
    type =
      with lib.types;
      listOf (submodule {
        inherit options;
      });
    default = [ ];
    description = ''
      Additional profiles configuration.

      > [!WARNING]
      >
      > Only paid accounts can set multiple profiles beside the default one.

      > [!NOTE]
      >
      > Additional profiles do not inherit the default profile options.
      >
      > Refer to [configuration example](../getting-started/examples.md#inherit-options-from-default-profile) for details on how to implement inheritance from default profile.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.activation = lib.hm.dag.entriesAfter "nixkraken-profiles" [ "nixkraken-top-level" ] (
      lib.mapAttrsToList (id: profile: ''
        ${localPkgs.configure}/bin/gk-configure \
          -c '${builtins.toJSON profile}' \
          -p ${id}
      '') profiles
    );
  };
}
