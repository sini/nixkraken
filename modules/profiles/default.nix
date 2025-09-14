{
  config,
  lib,
  localPkgs,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;

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
          builtins.replaceStrings [ "-" ] [ "" ] (genFakeUuid profile.name);
      terminal = profile.tools.terminal;
      defaultTerminal = if terminal.default == "gitkraken" then "Gitkraken Terminal" else "none";
      hasCustomTerminal = terminal.default == "custom";
      selectedTabId = genFakeUuid "selected-tab";
    in
    {
      ${id} = lib.attrsets.mergeAttrsList [
        {
          inherit (cfg.git) deleteOrigAfterMerge;
          inherit (cfg.ui) rememberTabs zoom;
          inherit defaultTerminal;

          autoFetchInterval = profile.git.fetchInterval;
          autoPrune = profile.git.autoPrune;
          autoUpdateSubmodules = profile.git.updateSubmodules;
          confictDetection.enabled = profile.git.detectConflicts;
          diffTool = profile.tools.diff;
          externalEditor = profile.tools.editor;
          git.selectedGitPath = if cfg.git.useBundledGit then "$packaged" else lib.getExe cfg.git.package;
          init.defaultBranch = profile.git.defaultBranch;
          layout.RefPanel.open = profile.ui.showLeftPanel;
          mergeTool = profile.tools.merge;
          profileIcon = profile.icon;
          useCustomTerminalCmd = hasCustomTerminal;
          userEmail = profile.user.email;
          userName = profile.user.name;

          cli = {
            cursorStyle = profile.ui.cli.cursor;
            defaultPath = profile.ui.cli.defaultPath;
            fontFamily = profile.ui.cli.fontFamily;
            fontSize = profile.ui.cli.fontSize;
            lineHeight = profile.ui.cli.lineHeight;
            position = profile.ui.cli.graph.position;
            showAutocompleteSuggestions = profile.ui.cli.autocomplete.enable;

            graphPanelVisibilityMode = if profile.ui.cli.graph.enable then "AUTO" else null;
            tabBehavior =
              let
                value = profile.ui.cli.autocomplete.tabBehavior;
              in
              if value == "ignore" then "DEFAULT" else lib.toUpper value;
          };

          editor = {
            fontFamily = profile.ui.editor.fontFamily;
            fontSize = profile.ui.editor.fontSize;
            lineEnding = profile.ui.editor.eol;
            tabSize = profile.ui.editor.tabSize;
            showLineNumbers = profile.ui.editor.lineNumbers;
            syntaxHighlighting = profile.ui.editor.syntaxHighlight;
            wordWrap = profile.ui.editor.wrap;
          };

          fileNodeList = {
            sort = "name_${profile.ui.sortOrder}";
            viewMode = if profile.ui.treeView then "tree_view" else "full_path";
          };

          focusView = {
            focusViewTabSettingsById = lib.listToAttrs (
              lib.map
                (
                  id:
                  lib.nameValuePair id {
                    settings = {
                      density = if profile.ui.launchpad.compact then "compact" else "standard";

                      fields = {
                        comments = profile.ui.launchpad.showComments;
                        fixVersions = profile.ui.launchpad.showFixVersions;
                        labels = profile.ui.launchpad.showLabels;
                        likes = profile.ui.launchpad.showLikes;
                        linesChanged = profile.ui.launchpad.showLinesChanged;
                        mentions = profile.ui.launchpad.showMentions;
                        milestones = profile.ui.launchpad.showMilestones;
                        sprints = profile.ui.launchpad.showSprints;
                        useInitials = profile.ui.launchpad.useAuthorInitials;
                      };
                    };
                  }
                )
                [
                  "personalPullRequest"
                  "personalIssue"
                  "personalWip"
                  "personalAll"
                  "personalSnoozed"
                  "teamPullRequest"
                  "teamIssue"
                ]
            );
          };

          gpg = {
            commitGpgSign = profile.gpg.signCommits != null && profile.gpg.signCommits;
            gpgFormat = profile.gpg.format;
            tagForceSignAnnotated = profile.gpg.signTags != null && profile.gpg.signTags;
          }
          // lib.optionalAttrs (profile.gpg.format == "openpgp") {
            gpgProgram = "${cfg.gpg.package}/${cfg.gpg.program}";
            userSigningKey = profile.gpg.signingKey;
          }
          // lib.optionalAttrs (profile.gpg.format == "ssh") {
            gpgSshProgram = "${cfg.gpg.package}/${cfg.gpg.program}";
            sshAllowedSignersFile = profile.gpg.allowedSigners;
            userSigningKeySsh = profile.gpg.signingKey;
          };

          ssh = {
            inherit (profile.git) useGitCredentialManager;
            inherit (profile.ssh) publicKey privateKey;

            appVersion = "${if cfg.package != null then cfg.package.version else cfg.version}";
            generated = false;
            useLocalAgent = profile.ssh.useLocalAgent;
          };

          tabInfo = {
            inherit selectedTabId;

            permanentTabs.FOCUS_VIEW.closed = cfg.ui.launchpad.collapsed;

            tabs = [
              (lib.optionalAttrs (cfg.skipTutorial) {
                id = selectedTabId;
                type = "NEW";
              })
            ];
          };

          ui = {
            highlightRowsOnRefHover = profile.graph.highlightRows;
            showGhostRefsOnHover = profile.graph.showGhostRefs;
            useAuthorInitialsForAvatars = profile.graph.useAuthorInitials;
            useGenericRemoteHostingServiceIconsInRefs = profile.graph.useGenericRemoteIcon;

            theme =
              let
                value = profile.ui.theme;
              in
              if value == "system" then "SYNC_WITH_SYSTEM" else value;

            graphOptions.columns = {
              author.visible = profile.graph.showAuthor;
              datetime.visible = profile.graph.showDatetime;
              sha.visible = profile.graph.showSHA;
              ref.visible = profile.graph.showRefs;

              graph = {
                mode = if profile.graph.compact then "compact" else "text";
                visible = profile.graph.showGraph;
              };

              message = {
                visible = profile.graph.showMessage;

                descDisplayMode =
                  let
                    value = profile.graph.showDesc;
                  in
                  if value == "hover" then "ON_HOVER" else lib.toUpper value;
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

  profiles = lib.attrsets.mergeAttrsList (map buildProfile (cfg.profiles ++ [ defaultProfile ]));
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
