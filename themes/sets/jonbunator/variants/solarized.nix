{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Solarized/solarized-dark";
  name = "solarized";
}
