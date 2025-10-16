{ lib, ... }:

{
  compact = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable compact graph columns.
      <!-- scope: profile -->
    '';
  };

  highlightRows = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Highlight associated rows when hovering over a branch.
      <!-- scope: profile -->
    '';
  };

  showAuthor = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit author.
      <!-- scope: profile -->
    '';
  };

  showDatetime = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit date/time.
      <!-- scope: profile -->
    '';
  };

  showDesc = lib.mkOption {
    type =
      with lib.types;
      nullOr (enum [
        "always"
        "hover"
        "never"
      ]);
    default = "always";
    description = ''
      Show commit description.
      <!-- scope: profile -->
    '';
  };

  showGhostRefs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show ghost branch/tag when hovering over or selecting a commit.
      <!-- scope: profile -->
    '';
  };

  showMessage = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show commit message.
      <!-- scope: profile -->
    '';
  };

  showRefs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show branches and tags.
      <!-- scope: profile -->
    '';
  };

  showSHA = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit SHA.
      <!-- scope: profile -->
    '';
  };

  showGraph = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show commit tree.
      <!-- scope: profile -->
    '';
  };

  useAuthorInitials = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use author initials instead of avatars.
      <!-- scope: profile -->
    '';
  };

  useGenericRemoteIcon = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use generic remote icon instead of hosting service icon.
      <!-- scope: profile -->
    '';
  };
}
