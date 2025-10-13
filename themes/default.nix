{
  # Allows to use 'nix build' or 'lib.callPackage'
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  inherit (pkgs) lib callPackage runCommand;

  allThemes = pkgs.lib.packagesFromDirectoryRecursive {
    inherit callPackage;

    directory = ./sets;
  };
in
runCommand "nixkraken-themes" {
  passthru = allThemes // {
    all = lib.attrValues allThemes;
  };
} "touch $out"
