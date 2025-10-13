{
  pkgs ? import <nixpkgs> { },
  name,
  path,
  prettyName ? null,
}:

pkgs.callPackage ../../make-theme.nix {
  inherit name prettyName;

  src = pkgs.fetchFromGitHub {
    owner = "jonbunator";
    repo = "gitkraken-custom-themes";
    rev = "v1.4.0";
    hash = "sha256-RCwitJ6HeFYJNsrc2lsVqAe1urfsi1RcxBYXXni6Fv0=";
  };

  path = "Themes/${path}.jsonc";

  meta = with pkgs.lib; {
    description = "Custom theme for GitKraken";
    homepage = "https://github.com/jonbunator/gitkraken-custom-themes";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
