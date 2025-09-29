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
// rec {
  show = pkgs.writeShellApplication {
    name = "show-tests";
    text = ''
      echo "Available tests:"
      for test in ${lib.concatStringsSep " " (lib.attrNames tests)}; do
        echo "  - $test"
      done
    '';
  };

  all =
    let
      # Dummy binary to avoid simply failing on 'nix run .#tests.all', inform caller on how to actually run tests and list available tests
      norun = pkgs.writeShellApplication {
        name = "norun";
        runtimeInputs = [ show ];
        text = ''
          >&2 echo
          >&2 echo "===== NOTICE ====="
          >&2 echo
          >&2 echo "The test suite is not meant to be run directly."
          >&2 echo
          >&2 echo "To build all tests, use:"
          >&2 echo -e "\t\$ nix build .#tests.all"
          >&2 echo
          >&2 echo "The tests have already been built, and the results are available here:"
          >&2 echo -e "\t> $(realpath -m "''${BASH_SOURCE[0]}/../../share")"
          >&2 echo
          >&2 echo "You can also run individual interactive tests like this:"
          >&2 echo -e "\t\$ nix run .#tests.<test-name>.driverInteractive"
          >&2 echo
          >&2 ${lib.getExe show}
          >&2 echo
          >&2 echo "=================="
        '';
      };
    in
    pkgs.stdenv.mkDerivation rec {
      name = "all-tests";
      src = ./.;

      # Using allTests attribute set values (actual imported tests) as buildInputs so they get build (i.e. tests are run as part of build)
      buildInputs = lib.attrValues allTests;
      nativeBuildInputs = [ norun ];

      installPhase = lib.concatLines (
        lib.flatten [
          ''
            runHook preInstall

            mkdir -p $out/bin
            install -m 0755 ${lib.getExe norun} $out/bin/${name}
          ''
          # Copy each test artifacts to a dedicated directory
          (lib.map (build: ''
            mkdir -p $out/share/${build.config.name}
            cp ${build.out}/snapshot.png $out/share/${build.config.name} || true
          '') buildInputs)
          ''
            runHook postInstall
          ''
        ]
      );
    };
}
