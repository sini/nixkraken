{
  lib,
  pkgs,
  ...
}:

let
  currentDir = ./.;
  packages = lib.filterAttrs (name: type: name != "default.nix") (builtins.readDir currentDir);
in
lib.mapAttrs (name: type: pkgs.callPackage (currentDir + "/${name}") { }) packages
