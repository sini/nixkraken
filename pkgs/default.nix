{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.lib.packagesFromDirectoryRecursive {
  directory = ./.;
  callPackage = pkgs.callPackage;
}
