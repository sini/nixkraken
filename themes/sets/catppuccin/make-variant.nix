{
  pkgs ? import <nixpkgs> { },
  name,
}:

pkgs.callPackage ../../make-theme.nix {
  inherit name;

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "gitkraken";
    rev = "1.1.0";
    hash = "sha256-df4m2WUotT2yFPyJKEq46Eix/2C/N05q8aFrVQeH1sA=";
  };

  path = "themes/catppuccin-${name}.jsonc";

  meta = with pkgs.lib; {
    description = "Soothing pastel theme for GitKraken";
    homepage = "https://github.com/catppuccin/gitkraken";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
