{
  pkgs ? import <nixpkgs> { },
}:

let
  localPkgs = import ./pkgs {
    inherit (pkgs) lib;
    inherit pkgs;
  };
in
pkgs.mkShellNoCC {
  nativeBuildInputs = pkgs.lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) localPkgs;
}
