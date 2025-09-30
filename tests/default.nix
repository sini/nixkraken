{
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  inherit (pkgs) lib;

  # Load all tests files from current directory, excluding this file and the '_common' directory
  currentDir = ./.;
  tests = lib.filterAttrs (name: type: name != "default.nix" && name != "_common") (
    builtins.readDir currentDir
  );

  # Build test using common conventions
  mkTest =
    name:
    let
      testImport = import (currentDir + "/${name}");
      test = if lib.isFunction testImport then testImport pkgs else testImport;
      machine = if test ? machine then test.machine else test;
      extraOpts = lib.optionalAttrs (test ? extraOpts) test.extraOpts;
    in
    pkgs.testers.runNixOSTest (
      (lib.filterAttrs (attr: _: attr != "test") extraOpts)
      // {
        inherit name;

        enableOCR = true;
        testScript = lib.readFile ./${name}/test.py;

        nodes.machine = machine // {
          imports = (lib.optional (machine ? imports) machine.imports) ++ [
            ./_common
          ];
        };
      }
    );

  # Import all tests in an attribute set with tests name as attributes name
  allTests = lib.mapAttrs (name: _: mkTest name) tests;
in
# Build attribute set of all tests and additional helper custom derivations
allTests
// rec {
  # List available tests for discovery
  show = pkgs.writeShellApplication {
    name = "show-tests";
    text = ''
      echo "Available tests:"
      for test in ${lib.concatStringsSep " " (lib.attrNames tests)}; do
        echo "  - $test"
      done
    '';
  };

  # Build all tests altogether
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
