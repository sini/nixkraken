{
  config,
  lib,
  localPkgs,
  pkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;

  # Function to get the value of an attribute in the given 'profile' at path 'attrPath' or fallback to "default" profile (top-level option)
  # If the attribute is found but null, fallback to "default" profile too
  fromProfileOrDefault =
    profile: attrPath:
    let
      resolved = lib.attrByPath attrPath (lib.getAttrFromPath attrPath cfg) profile;
    in
    if (resolved == null || resolved == "") then lib.getAttrFromPath attrPath cfg else resolved;

  # Function to generate a fake UUID string from a SHA512 hash of a seed string
  # Generates a map with the first 32 characters of the hash split in groups of
  # different size and concatenate them in a string, each group separated by dashes
  # Note: using the same seed will always generate the same UUID
  genFakeUuid =
    seed:
    lib.concatStringsSep "-" (
      builtins.foldl'
        (
          acc: elem:
          acc
          ++ lib.singleton (
            lib.substring (lib.elemAt elem 0) (lib.elemAt elem 1) (builtins.hashString "sha512" seed)
          )
        )
        [ ]
        [
          [
            0
            8
          ]
          [
            8
            4
          ]
          [
            12
            4
          ]
          [
            16
            4
          ]
          [
            20
            12
          ]
        ]
    );

  buildProfile =
    profile:
    let
      id =
        if profile.isDefault then
          # From GitKraken's prettified main.bundle.js:
          # (re.defaultProfileGuid = "d6e5a8ca26e14325a4275fc33b17e16f"),
          "d6e5a8ca26e14325a4275fc33b17e16f"
        else
          # Profile ids are random UUIDs with dashes removed
          builtins.replaceStrings [ "-" "" ] (genFakeUuid profile.name);
      terminal = fromProfileOrDefault profile [
        "tools"
        "terminal"
      ];
      defaultTerminal = if terminal.default == "gitkraken" then "Gitkraken Terminal" else "none";
      hasCustomTerminal = terminal.default == "custom";
      selectedTabId = genFakeUuid "selected-tab";
    in
    {
      ${id} = lib.attrsets.mergeAttrsList [
        {
          inherit (cfg.git) deleteOrigAfterMerge;
          inherit (cfg.ui) rememberTabs;
          inherit defaultTerminal;

          autoFetchInterval = fromProfileOrDefault profile [
            "git"
            "autoFetchInterval"
          ];
          autoPrune = fromProfileOrDefault profile [
            "git"
            "autoPrune"
          ];
          autoUpdateSubmodules = fromProfileOrDefault profile [
            "git"
            "autoUpdateSubmodules"
          ];
          diffTool = fromProfileOrDefault profile [
            "tools"
            "diff"
          ];
          externalEditor = fromProfileOrDefault profile [
            "tools"
            "editor"
          ];
          git.selectedGitPath = if cfg.git.useBundledGit then "$packaged" else lib.getExe cfg.git.package;
          init.defaultBranch = fromProfileOrDefault profile [
            "git"
            "defaultBranch"
          ];
          mergeTool = fromProfileOrDefault profile [
            "tools"
            "merge"
          ];
          profileIcon = profile.icon;
          useCustomTerminalCmd = hasCustomTerminal;
          userEmail = fromProfileOrDefault profile [
            "user"
            "email"
          ];
          userName = fromProfileOrDefault profile [
            "user"
            "name"
          ];

          cli = {
            cursorStyle = fromProfileOrDefault profile [
              "ui"
              "cli"
              "cursor"
            ];
            defaultPath = fromProfileOrDefault profile [
              "ui"
              "cli"
              "defaultPath"
            ];
            fontFamily = fromProfileOrDefault profile [
              "ui"
              "cli"
              "fontFamily"
            ];
            fontSize = fromProfileOrDefault profile [
              "ui"
              "cli"
              "fontSize"
            ];
            lineHeight = fromProfileOrDefault profile [
              "ui"
              "cli"
              "lineHeight"
            ];
            position = fromProfileOrDefault profile [
              "ui"
              "cli"
              "graph"
              "position"
            ];
            showAutocompleteSuggestions = fromProfileOrDefault profile [
              "ui"
              "cli"
              "autocomplete"
              "enable"
            ];

            graphPanelVisibilityMode =
              if
                fromProfileOrDefault profile [
                  "ui"
                  "cli"
                  "graph"
                  "enable"
                ]
              then
                "AUTO"
              else
                null;
            tabBehavior =
              let
                value = fromProfileOrDefault profile [
                  "ui"
                  "cli"
                  "autocomplete"
                  "tabBehavior"
                ];
              in
              if value == "ignore" then "DEFAULT" else lib.toUpper value;
          };

          editor = {
            fontFamily = fromProfileOrDefault profile [
              "ui"
              "editor"
              "fontFamily"
            ];
            fontSize = fromProfileOrDefault profile [
              "ui"
              "editor"
              "fontSize"
            ];
            lineEnding = fromProfileOrDefault profile [
              "ui"
              "editor"
              "eol"
            ];
            tabSize = fromProfileOrDefault profile [
              "ui"
              "editor"
              "tabSize"
            ];
            showLineNumbers = fromProfileOrDefault profile [
              "ui"
              "editor"
              "showLineNumbers"
            ];
            syntaxHighlighting = fromProfileOrDefault profile [
              "ui"
              "editor"
              "syntaxHighlighting"
            ];
            wordWrap = fromProfileOrDefault profile [
              "ui"
              "editor"
              "wrap"
            ];
          };

          gpg = {
            commitGpgSign = fromProfileOrDefault profile [
              "gpg"
              "signCommits"
            ];
            gpgFormat = "openpgp";
            gpgProgram = fromProfileOrDefault profile [
              "gpg"
              "package"
            ];
            tagForceSignAnnotated = fromProfileOrDefault profile [
              "gpg"
              "signTags"
            ];
            userSigningKey = fromProfileOrDefault profile [
              "gpg"
              "signingKey"
            ];
            userSigningKeySsh = null;
          };

          ssh = {
            appVersion = "${if cfg.package != null then cfg.package.version else cfg.version}";
            generated = false;
            publicKey = fromProfileOrDefault profile [
              "ssh"
              "publicKey"
            ];
            privateKey = fromProfileOrDefault profile [
              "ssh"
              "privateKey"
            ];
            useLocalAgent = fromProfileOrDefault profile [
              "ssh"
              "useLocalAgent"
            ];
          };

          tabInfo = {
            inherit selectedTabId;

            # TODO: enable back when ui.launchpad.collapsed exists
            # permanentTabs.FOCUS_VIEW.closed = cfg.collapsePermanentTabs;

            tabs = [
              (lib.optionalAttrs (cfg.skipTutorial) {
                id = selectedTabId;
                type = "NEW";
              })
            ];
          };

          ui = {
            highlightRowsOnRefHover = fromProfileOrDefault profile [
              "graph"
              "highlightRowsOnRefHover"
            ];
            showGhostRefsOnHover = fromProfileOrDefault profile [
              "graph"
              "showGhostRefsOnHover"
            ];
            useAuthorInitialsForAvatars = fromProfileOrDefault profile [
              "graph"
              "useAuthorInitials"
            ];
            useGenericRemoteHostingServiceIconsInRefs = fromProfileOrDefault profile [
              "graph"
              "useGenericRemoteIcon"
            ];

            theme =
              let
                value = fromProfileOrDefault profile [
                  "ui"
                  "theme"
                ];
              in
              if value == "system" then "SYNC_WITH_SYSTEM" else value;

            graphOptions.columns = {
              author.visible = fromProfileOrDefault profile [
                "graph"
                "showAuthor"
              ];
              datetime.visible = fromProfileOrDefault profile [
                "graph"
                "showDatetime"
              ];
              sha.visible = fromProfileOrDefault profile [
                "graph"
                "showSHA"
              ];
              ref.visible = fromProfileOrDefault profile [
                "graph"
                "showRefs"
              ];

              graph = {
                visible = fromProfileOrDefault profile [
                  "graph"
                  "showGraph"
                ];

                mode =
                  let
                    value = fromProfileOrDefault profile [
                      "graph"
                      "compact"
                    ];
                  in
                  if value == true then "compact" else "text";
              };

              message = {
                visible = fromProfileOrDefault profile [
                  "graph"
                  "showMessage"
                ];

                descDisplayMode =
                  let
                    value = fromProfileOrDefault profile [
                      "graph"
                      "showDesc"
                    ];
                  in
                  if value == "hover" then "ON_HOVER" else lib.optional (value != null) (lib.toUpper value);
              };
            };
          };
        }
        (if (profile.name != null) then { profileName = profile.name; } else { })
        (
          if hasCustomTerminal then
            {
              customTerminalCmd = lib.concatStringsSep " " [
                "${
                  if lib.isStorePath terminal.bin then terminal.bin else terminal.package + "/bin/" + terminal.bin
                }"
                terminal.extraOptions
              ];
            }
          else
            { }
        )
      ];
    };

  profiles = lib.attrsets.mergeAttrsList (map buildProfile cfg.profiles);
in
{
  options.programs.nixkraken.profiles = lib.mkOption {
    type =
      with lib.types;
      listOf (submodule {
        inherit options;
      });
    default = [ { isDefault = true; } ];
    description = ''
      Profiles configuration.

      All settings in a profile take precedence over global settings.

      Example: if a profile defines the `ssh` option and the global `ssh` option is defined, the profile-specific option will be used.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let
        defaultProfileCount = lib.length (lib.filter (profile: profile.isDefault) cfg.profiles);
        profilesWithoutNameCount = lib.length (
          lib.filter (profile: !profile.isDefault && profile.name == null) cfg.profiles
        );
      in
      [
        {
          assertion = defaultProfileCount == 1;
          message =
            if defaultProfileCount > 1 then
              "Only one default profile (`profile.isDefault = true`) must be defined"
            else
              "A default profile (`profile.isDefault = true`) is required";
        }
        {
          assertion = profilesWithoutNameCount == 0;
          message = "Non-default profiles (`profile.isDefault = false`) must have a name";
        }
      ];

    home.activation = lib.hm.dag.entriesAfter "nixkraken-profiles" [ "nixkraken-top-level" ] (
      lib.mapAttrsToList (id: profile: ''
        ${localPkgs.configure}/bin/gk-configure \
          -c '${builtins.toJSON profile}' \
          -p ${id}
      '') profiles
    );
  };
}
