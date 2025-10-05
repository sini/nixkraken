{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Oled Dream/oled-dream";
  name = "oled-dream";
}
