{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "TheMatrix/matrix";
  name = "the-matrix";
}
