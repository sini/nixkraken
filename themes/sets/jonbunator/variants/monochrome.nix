{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Monochrome/monochrome-dark";
  name = "monochrome";
}
