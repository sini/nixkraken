{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "TokyoNight/tokyo-night-dark";
  name = "tokyo-night";
}
