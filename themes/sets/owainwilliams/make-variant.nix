{
  pkgs ? import <nixpkgs> { },
  name,
  path,
  prettyName ? null,
}:

let
  src = import ./source.nix;
  meta = import ./meta.nix pkgs.lib;
in
pkgs.callPackage ../../make-theme.nix {
  inherit
    src
    meta
    name
    prettyName
    ;

  path = "${path}.jsonc";
}
