{
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  inherit (pkgs) callPackage lib;

  localPkgs = lib.packagesFromDirectoryRecursive {
    inherit callPackage;

    directory = ./.;
  };
in
lib.filterAttrs (name: _: name != "default") localPkgs
