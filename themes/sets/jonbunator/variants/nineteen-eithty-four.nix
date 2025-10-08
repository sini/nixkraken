{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ../make-variant.nix {
  path = "1984/1984-dark";
  name = "nineteen-eighty-four";
  prettyName = "1984";
}
