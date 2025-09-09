{
  lib,
  stdenvNoCC,
  nixosOptionsDoc,
  mdbook,
  mdbook-alerts,
  mdbook-linkcheck,
  mdbook-pagetoc,
  nodejs,
  rustc,
}:

let
  moduleEval = lib.evalModules {
    modules = [
      (_: {
        imports = [ ../module.nix ];
        config._module.check = false;
      })
    ];
  };

  optionsDoc = nixosOptionsDoc {
    inherit (moduleEval) options;
  };

  gitkrakenVersions = import ../gitkraken/versions.nix;
  cachedCommitsList = lib.mapAttrsToList (
    version:
    { commit, ... }:
    "> - GitKraken v${version}: [\\`${commit}\\`](https://github.com/nixos/nixpkgs/blob/${commit})"
  ) gitkrakenVersions;
in
stdenvNoCC.mkDerivation {
  name = "nixkraken-docs";
  src = ./.;

  nativeBuildInputs = [
    nodejs
    mdbook
    mdbook-alerts
    mdbook-linkcheck
    mdbook-pagetoc
  ];

  dontConfigure = true;
  doCheck = true;
  dontFixup = true;

  # Patch book configuration to disable web links checking since network is not available
  patches = [ ./book.toml.nix-build.patch ];

  preBuild = ''
    node build-doc.js ${optionsDoc.optionsJSON}/share/doc/nixos/options.json
    substituteInPlace src/getting-started/caching.md --replace-fail "> @CACHED_COMMIT_LIST@" "${lib.concatStringsSep "\n" cachedCommitsList}"
  '';

  buildPhase = ''
    runHook preBuild

    mdbook build

    runHook postBuild
  '';

  nativeCheckInputs = [
    mdbook
    mdbook-alerts
    mdbook-linkcheck
    mdbook-pagetoc
    rustc
  ];

  checkPhase = ''
    runHook preCheck

    mdbook test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mv book/html $out

    runHook postInstall
  '';
}
