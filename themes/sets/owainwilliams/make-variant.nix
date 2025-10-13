{
  pkgs ? import <nixpkgs> { },
  name,
  path,
  prettyName ? null,
}:

pkgs.callPackage ../../make-theme.nix {
  inherit name prettyName;

  src = pkgs.fetchFromGitHub {
    owner = "owainwilliams";
    repo = "gitkrakenthemes";
    rev = "8.3.0";
    hash = "sha256-W65IkaerLBpWWUvYtfr/ESKVTvWyqXWwgcVJaiU9aW4=";
  };

  path = "${path}.jsonc";

  meta = with pkgs.lib; {
    description = "Custom theme for GitKraken";
    homepage = "https://github.com/jonbunator/gitkraken-custom-themes";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
