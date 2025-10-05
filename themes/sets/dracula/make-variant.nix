{
  pkgs ? import <nixpkgs> { },
  name ? null,
}@args:

let
  src = import ./source.nix;
  meta = import ./meta.nix pkgs.lib;
in
pkgs.callPackage ../../make-theme.nix {
  inherit src meta;

  name = args.name or "dracula";
  path = "dracula-theme${if name == null then "" else "-${args.name}"}.jsonc";
}
