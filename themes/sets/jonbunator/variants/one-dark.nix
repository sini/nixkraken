{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "OneDark/one-dark";
  name = "one-dark";
  prettyName = "OneDark";
}
