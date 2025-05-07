{
  pkgs ? import <nixpkgs> { },
  self,
}:

let
  localPkgs = import ./pkgs {
    inherit pkgs;
    inherit (pkgs) lib;
    inherit self;
  };
in
pkgs.mkShellNoCC {
  nativeBuildInputs = pkgs.lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) localPkgs;
}
