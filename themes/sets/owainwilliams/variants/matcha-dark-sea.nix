{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Matcha-Dark-Sea/matcha";
  name = "matcha-dark-sea";
}
