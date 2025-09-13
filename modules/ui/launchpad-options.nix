{ lib, ... }:

{
  collapsed = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Collapse Launchpad tab.
    '';
  };

  compact = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable compact Launchpad view.
    '';
  };

  showComments = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show comments.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
    '';
  };

  showFixVersions = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show fix versions.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
    '';
  };

  showLabels = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show labels.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
    '';
  };

  showLikes = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show likes.
    '';
  };

  showLinesChanged = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show lines changed.

      This setting is relevant in the following Launchpad views: Personal PR, Personal all, Personal snoozed, Team PR.
    '';
  };

  showMentions = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show mentions.
    '';
  };

  showMilestones = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show milestones.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
    '';
  };

  showSprints = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show sprints.

      This setting is relevant in the following Launchpad views: Personal Issues, Personal all, Personal snoozed, Team issues.
    '';
  };

  useAuthorInitials = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use author initials instead of avatars.

      This setting is relevant in the following Launchpad views: Personal PR, Personal Issues, Personal all, Personal snoozed, Team PR, Team issues.
    '';
  };
}
