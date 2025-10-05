{
  pkgs ? import <nixpkgs> { },
  set ? null,
  variant ? null,
  ...
}:

let
  inherit (pkgs) callPackage lib runCommand;
in
if set != null then
  callPackage ./make-set-variants.nix {
    inherit set variant;
  }
else
  runCommand "nixkraken-themes" {
    passthru = lib.packagesFromDirectoryRecursive {
      inherit callPackage;

      directory = ./sets;
    };
  } "touch $out"
