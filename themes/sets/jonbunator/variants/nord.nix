{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Nord/nord-dark";
  name = "nord";
}
