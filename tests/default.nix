{
  fetchFromGitHub,
  lib,
  system,
  ...
}:

let
  # WARN: when updating this, remember to update home-manager in tests/common/nixkraken.nix too
  nixpkgs = fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "nixos-25.05";
    # nix-prefetch-git --url git@github.com:nixos/nixpkgs.git --rev refs/heads/nixos-25.05 --quiet | jq -r .hash
    hash = "sha256-aSgK4BLNFFGvDTNKPeB28lVXYqVn8RdyXDNAvgGq+k0=";
  };
  pkgs = import nixpkgs {
    inherit system;

    # GitKraken is unfree software, make sure to allow it
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "gitkraken"
      ];

    overlays = [ ];
  };

  # Load all tests files from current directory, excluding this file and the '_common' directory
  currentDir = ./.;
  tests = lib.filterAttrs (name: type: name != "default.nix" && name != "_common") (
    builtins.readDir currentDir
  );

  # Import all tests in an attribute set with tests name as attributes name
  # i.e. { enable = import ./enable; accept-eula = import ./accept-eula; /* ... */ }
  allTests = lib.mapAttrs (name: type: import (currentDir + "/${name}") { inherit pkgs; }) tests;
in
# Build attribute set of all tests and a custom derivation running all tests altogether
allTests
// {
  all = pkgs.runCommand "all-tests" {
    # Using allTests attribute set values (actual imported tests) as buildInputs so they get build (i.e. tests are run as part of build)
    buildInputs = lib.attrValues allTests;
  } "touch $out";
}
