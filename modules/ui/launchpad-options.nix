{ lib, ... }:

{
  collapsed = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Collapse Launchpad tab.
      <!-- scope: profile -->
    '';
  };

  compact = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable compact Launchpad view.
      <!-- scope: profile -->
    '';
  };

  showComments = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show comments.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
      <!-- scope: profile -->
    '';
  };

  showFixVersions = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show fix versions.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
      <!-- scope: profile -->
    '';
  };

  showLabels = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show labels.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
      <!-- scope: profile -->
    '';
  };

  showLikes = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show likes.
      <!-- scope: profile -->
    '';
  };

  showLinesChanged = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show lines changed.

      This setting is relevant in the following Launchpad views: Personal PR, Personal all, Personal snoozed, Team PR.
      <!-- scope: profile -->
    '';
  };

  showMentions = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show mentions.
      <!-- scope: profile -->
    '';
  };

  showMilestones = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show milestones.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
      <!-- scope: profile -->
    '';
  };

  showSprints = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show sprints.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
      <!-- scope: profile -->
    '';
  };

  useAuthorInitials = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use author initials instead of avatars.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
      <!-- scope: profile -->
    '';
  };
}
