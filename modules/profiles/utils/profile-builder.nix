{ cfg, lib, ... }:

let
  genUUID = import ./uuid.nix lib;
  profileIcons = import ./profile-icons.nix;
in
profile:
let
  id =
    if profile.isDefault then
      # From GitKraken's prettified main.bundle.js:
      # (re.defaultProfileGuid = "d6e5a8ca26e14325a4275fc33b17e16f"),
      "d6e5a8ca26e14325a4275fc33b17e16f"
    else
      # Profile ids are random UUIDs with dashes removed
      builtins.replaceStrings [ "-" ] [ "" ] (genUUID profile.name);
  selectedTabId = genUUID "selected-tab";
in
{
  ${id} = lib.attrsets.mergeAttrsList [
    {
      inherit (profile.git) deleteOrigAfterMerge;
      inherit (profile.ui) rememberTabs;

      autoFetchInterval = profile.git.fetchInterval;
      autoPrune = profile.git.autoPrune;
      autoUpdateSubmodules = profile.git.updateSubmodules;
      conflictDetection.enabled = profile.git.detectConflicts;
      diffTool = profile.tools.diff;
      git.selectedGitPath = if cfg.git.useBundledGit then "$packaged" else lib.getExe cfg.git.package;
      init.defaultBranch = profile.git.defaultBranch;
      layout.RefPanel.open = profile.ui.showLeftPanel;
      mergeTool = profile.tools.merge;
      profileIcon = profileIcons.${profile.icon};
      userEmail = profile.user.email;
      userName = profile.user.name;
      workDirSummary = profile.ui.showRepoSummary;

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

      externalTools = {
        editor =
          let
            hasExternalEditor = profile.tools.editor.package != null;
          in
          {
            externalEditorType = if hasExternalEditor then "custom" else "none";

            customEditor = lib.optionalAttrs hasExternalEditor {
              path = lib.getExe profile.tools.editor.package;

              commands = {
                file = profile.tools.editor.fileExtraOptions;
                repo = profile.tools.editor.repoExtraOptions;
              };
            };
          };

        terminal =
          let
            hasExternalTerminal = profile.tools.terminal.package != null;
          in
          {
            externalTerminalType = if hasExternalTerminal then "custom" else "builtIn";

            customTerminal = lib.optionalAttrs hasExternalTerminal {
              command = profile.tools.terminal.extraOptions;
              path = lib.getExe profile.tools.terminal.package;
            };
          };
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
  ];
}
