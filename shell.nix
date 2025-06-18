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
  nativeBuildInputs = (with pkgs; [
    mdbook
    mdbook-alerts
    mdbook-pagetoc
    nodejs
  ]) ++ pkgs.lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) localPkgs;
}
