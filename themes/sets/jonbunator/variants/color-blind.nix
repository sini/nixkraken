{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Default Themes Modified/dark-color-blind";
  name = "color-blind";
}
