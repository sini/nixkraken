{ lib, ... }@args:

let
  commitGraph.options = import ../graph/common-options.nix args;
  git.options = import ../git/common-options.nix args;
  gpg.options = import ../gpg/options.nix args;
  ssh.options = import ../ssh/options.nix args;
  tools.options = import ../tools/options.nix args;
  ui.options = import ../ui/common-options.nix args;
  user.options = import ../user/options.nix args;

  # From GitKraken's prettified main.bundle.js:
  # ae = (re.ICONS = [
  #   { name: "Keif, the Kraken", path: "Keif.png" },
  #  ../* ... */
  # ]),
  # NOTE: when updating, DO NOT delete the "gravatar" entry (even if it's not listed in GitKraken's code)
  icons = [
    "Aqua-Keif.png" # AquaKeif
    "Architect-Keif.png" # Architect Keif
    "Brainy-Keif.png" # Brainy Keif
    "Butler-Keif.png" # Butler Keif
    "Capt-FalKeif.png" # Captain FalKeif
    "Developer-Keif1.png" # Developer Keif
    "Developer-Keif2.png" # Developer Keif
    "Dia-de-los-Muertos-Keif.png" # Dia de los Muertos
    "Flash-Keif.png" # Flash Keif
    "Git-Mage-Keif.png" # Git Mage
    "Gitty-up.png" # Gitty Up
    "Gourmet-Keif.png" # Gourmet Sh*t
    "Headphones-Keif.png" # Headphones Keif
    "Keif-Snow.png" # Keif Snow
    "Keif-Stanz.png" # Dr. Keif Stanz
    "Keif-the-Riveter.png" # Kefie the Riveter
    "Keif.png" # Keif, the Kraken
    "Keifa-Lovelace.png" # Keifa Lovelace
    "Keifachu.png" # Detective Keifachu
    "Keifer-Simpson.png" # Keifer Simpson
    "Keiferella.png" # Keiferella
    "Keiflo-Ren.png" # Keiflo Ren
    "Keiflock-Holmes.png" # Keiflock Holmes
    "Keifuto.png" # Keifuto
    "Kraken-Hook.png" # Kraken Hook
    "Kraken-who-lived.png" # The Kraken Who Lived
    "Krakener-Things.png" # Stranger Krakens
    "Kraknos.png" # Kraknos
    "Leprekraken.png" # Leprekraken
    "Link-Keif.png" # LinKeif
    "Lumber-Keif.png" # LumberKeif
    "Martian-Keif.png" # Martian Kraken
    "Mother-of-Krakens.png" # Mother of Krakens
    "Neo-Keif.png" # Neo Keif
    "OG-Keif.png" # OG
    "Power-Gitter.png" # Power Gitter
    "Princess-Keifia.png" # Princess Keifia
    "Pro-Keif.png" # Pro Keif
    "Professor-Keif.png" # Albert Keifstein
    "Rasta-Keif.png" # Rasta Keif
    "Rise-of-SkyKraken.png" # Rise of SkyKraken
    "Santa-Keif.png" # Kaken Claus
    "Sir-Keif.png" # Sir Keif
    "Snow-Kraken.png" # Snowkraken
    "Space-Rocket-Keif.png" # Space Rocket Keif
    "The-Bride-Keif.png" # Uma Kraken
    "Thunder-Kraken.png" # Thunder Kraken
    "Top-Git.png" # Top Git
    "Vanilla-Keif.png" # Vanilla Keif
    "Velma-Keif.png" # Velma Keif
    "Wonder-Kraken.png" # Wonder Kraken
    "Yoda-Keif.png" # Yoda Keif
    "gravatar"
  ];

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
    type = lib.types.bool;
    default = false;
    description = ''
      Set profile as default.

      Note: there can be only one default profile.

      **WARNING:** only paid accounts can set multiple profiles.
    '';
  };

  name = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    description = ''
      Name of the profile displayed in GitKraken.

      Note: this must be set to a string for any profile where `isDefault` is false.
    '';
  };

  icon = lib.mkOption {
    type = lib.types.enum icons;
    default = "gravatar";
    description = ''
      Icon avatar displayed in GitKraken.
    '';
  };

  commitGraph = mkProfileSubmodule commitGraph.options "Commit graph settings for this profile.";
  git = mkProfileSubmodule git.options "Git settings for this profile.";
  gpg = mkProfileSubmodule gpg.options "GPG settings for this profile.";
  ssh = mkProfileSubmodule ssh.options "SSH settings for this profile.";
  tools = mkProfileSubmodule tools.options "External tools settings for this profile.";
  ui = mkProfileSubmodule ui.options "UI settings for this profile.";
  user = mkProfileSubmodule user.options "User settings for this profile.";
}
