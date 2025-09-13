{ lib, ... }:

{
  compact = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Enable compact graph columns.
    '';
  };

  highlightRowsOnRefHover = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Highlight associated rows when hovering over a branch.
    '';
  };

  showAuthor = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show commit author.
    '';
  };

  showDatetime = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
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
    default = null;
    description = ''
      Show commit description.
    '';
  };

  showGhostRefsOnHover = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show ghost branch/tag when hovering over or selecting a commit.
    '';
  };

  showMessage = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show commit message.
    '';
  };

  showRefs = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show branches and tags.
    '';
  };

  showSHA = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show commit SHA.
    '';
  };

  showGraph = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Show commit tree.
    '';
  };

  useAuthorInitials = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Use author initials instead of avatars.
    '';
  };

  useGenericRemoteIcon = lib.mkOption {
    type = with lib.types; nullOr bool;
    default = null;
    description = ''
      Use generic remote icon instead of hosting service icon.
    '';
  };
}
