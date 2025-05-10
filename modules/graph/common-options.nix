{ lib, ... }:

{
  highlightRowsOnRefHover = lib.mkOption {
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

  showDescription = lib.mkOption {
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

  showGhostRefsOnHover = lib.mkOption {
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

  showSha = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Show commit SHA.
    '';
  };

  showTree = lib.mkOption {
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
