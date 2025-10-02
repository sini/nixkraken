{
  pkgs ? import <nixpkgs> { },
}:

let
  convco = import ./convco.nix { inherit pkgs; };
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
    ++ [ convco ]
    ++ pkgs.lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) localPkgs;

  shellHook = ''
    find .hooks \
      -maxdepth 1 \
      -type f \
      -name '*.sh' \
      -exec bash -c 'ln -sf "$PWD/$1" ".git/hooks/$(basename "$1" .sh)"' _ {} \;
  '';
}
