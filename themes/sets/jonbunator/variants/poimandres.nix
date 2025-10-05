{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Poimandres/poimandres-dark";
  name = "poimandres";
}
