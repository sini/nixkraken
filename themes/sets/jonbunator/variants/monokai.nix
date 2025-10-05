{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "Monokai/monokai-dark";
  name = "monokai";
}
