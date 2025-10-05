{
  pkgs ? import <nixpkgs> { },
  name,
}:

let
  src = import ./source.nix;
  meta = import ./meta.nix pkgs.lib;
in
pkgs.callPackage ../../make-theme.nix {
  inherit src meta name;

  path = "themes/catppuccin-${name}.jsonc";
}
