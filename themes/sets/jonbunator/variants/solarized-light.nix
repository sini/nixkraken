{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Solarized/solarized-light";
  name = "solarized-light";
  prettyName = "Solarized Light";
}
