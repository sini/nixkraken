{
  pkgs ? import <nixpkgs> { },
  set,
  variant ? null,
}:

let
  inherit (pkgs) callPackage lib;

  getVariant = variant: callPackage ./sets/${set}/variants/${variant}.nix;
in
if variant != null then
  getVariant variant
else
  lib.packagesFromDirectoryRecursive {
    inherit callPackage;

    directory = ./sets/${set}/variants;
  }
