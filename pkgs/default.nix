{
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  inherit (pkgs) lib;

  localPkgs = lib.packagesFromDirectoryRecursive {
    directory = ./.;
    callPackage = pkgs.callPackage;
  };
in
lib.filterAttrs (name: _: name != "default") localPkgs
