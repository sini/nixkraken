{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix { }
