{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "NightOwl/night-owl-light";
  name = "light-owl";
  prettyName = "Light Owl";
}
