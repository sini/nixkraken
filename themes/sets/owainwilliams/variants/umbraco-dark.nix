{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Umbraco-Dark/umbraco-dark";
  name = "umbraco-dark";
}
