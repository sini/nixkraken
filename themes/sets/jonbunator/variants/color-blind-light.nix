{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Default Themes Modified/light-color-blind";
  name = "color-blind-light";
}
