{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "NightOwl/night-owl-dark";
  name = "night-owl";
  prettyName = "Night Owl";
}
