{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;

  localPkgs = import ./pkgs pkgs;
in
pkgs.mkShellNoCC {
  nativeBuildInputs =
    (with pkgs; [
      mdbook
      mdbook-alerts
      mdbook-linkcheck
      nodejs
      rustc
    ])
    ++ lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) (
      lib.filterAttrs (attr: _: attr != "default") localPkgs
    );

  shellHook = ''
    find .hooks \
      -maxdepth 1 \
      -type f \
      -name '*.sh' \
      -exec bash -c 'ln -sf "$PWD/$1" ".git/hooks/$(basename "$1" .sh)"' _ {} \;
  '';
}
