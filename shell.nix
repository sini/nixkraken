{
  pkgs ? import <nixpkgs> { },
}:

let
  localPkgs = import ./pkgs {
    inherit (pkgs) lib;
    inherit pkgs;
  };
in
pkgs.mkShellNoCC {
  nativeBuildInputs =
    (with pkgs; [
      mdbook
      mdbook-alerts
      mdbook-pagetoc
      mdbook-linkcheck
      nodejs
      rustc
    ])
    ++ pkgs.lib.mapAttrsToList (pkg: _: localPkgs.${pkg}) localPkgs;

  shellHook = ''
    {
      echo "#!/usr/bin/env bash"
      echo "nix flake check"
    } > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
  '';
}
