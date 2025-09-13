{ lib, ... }:

{
  compact = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable compact graph columns.
    '';
  };

  highlightRows = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Highlight associated rows when hovering over a branch.
    '';
  };

  showAuthor = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit author.
    '';
  };

  showDatetime = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit date/time.
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
    '';
  };

  showGhostRefs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show ghost branch/tag when hovering over or selecting a commit.
    '';
  };

  showMessage = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show commit message.
    '';
  };

  showRefs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show branches and tags.
    '';
  };

  showSHA = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit SHA.
    '';
  };

  showGraph = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Show commit tree.
    '';
  };

  useAuthorInitials = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use author initials instead of avatars.
    '';
  };

  useGenericRemoteIcon = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use generic remote icon instead of hosting service icon.
    '';
  };
}
