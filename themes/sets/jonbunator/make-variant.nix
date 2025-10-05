{
  pkgs ? import <nixpkgs> { },
  name,
  path,
}:

let
  src = import ./source.nix;
  meta = import ./meta.nix pkgs.lib;
in
pkgs.callPackage ../../make-theme.nix {
  inherit src meta name;

  path = "Themes/${path}.jsonc";
}
