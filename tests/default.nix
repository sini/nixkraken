{ lib, pkgs, ... }:

let
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
