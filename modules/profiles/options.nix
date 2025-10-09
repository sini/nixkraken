{ lib, ... }@args:

let
  profileIcons = import ./utils/profile-icons.nix;

  graph.options = import ../graph/profile-options.nix args;
  git.options = import ../git/profile-options.nix args;
  gpg.options = import ../gpg/options.nix args;
  ssh.options = import ../ssh/options.nix args;
  tools.options = import ../tools/profile-options.nix args;
  ui.options = import ../ui/profile-options.nix args;
  user.options = import ../user/options.nix args;

  mkProfileSubmodule =
    options: description:
    lib.mkOption {
      inherit description;

      type = lib.types.submodule {
        inherit options;
      };
      default = { };
    };
in
{
  isDefault = lib.mkOption {
    internal = true;
    type = lib.types.bool;
    default = false;
  };

  name = lib.mkOption {
    type = lib.types.str;
    default = null;
    description = ''
      Name of this profile.
    '';
  };

  icon = lib.mkOption {
    type = lib.types.enum (lib.attrNames profileIcons);
    default = "Gravatar";
    description = ''
      Icon avatar for this profile.
    '';
  };

  graph = mkProfileSubmodule graph.options "Commit graph settings for this profile.";
  git = mkProfileSubmodule git.options "Git settings for this profile.";
  gpg = mkProfileSubmodule gpg.options "GPG settings for this profile.";
  ssh = mkProfileSubmodule ssh.options "SSH settings for this profile.";
  tools = mkProfileSubmodule tools.options "External tools settings for this profile.";
  ui = mkProfileSubmodule ui.options "UI settings for this profile.";
  user = mkProfileSubmodule user.options "User settings for this profile.";
}
