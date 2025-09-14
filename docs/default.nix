{
  lib,
  stdenvNoCC,
  nixosOptionsDoc,
  mdbook,
  mdbook-alerts,
  mdbook-linkcheck,
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
  ];

  dontConfigure = true;
  doCheck = true;
  dontFixup = true;

  # Patch book configuration to disable web links checking since network is not available
  patches = [ ./book.toml.nix-build.patch ];

  preBuild = ''
    node build-doc.js ${optionsDoc.optionsJSON}/share/doc/nixos/options.json
    substituteInPlace src/getting-started/caching.md --replace-fail "> @CACHED_COMMIT_LIST@" "${lib.concatStringsSep "\n" cachedCommitsList}"
    for f in $(find src/options -type f -name '*.md'); do
      fdir=$(dirname $f)
      rel_root=$(realpath --relative-to=$fdir src/options)
      substituteInPlace $f --subst-var-by OPTIONS_ROOT $rel_root
    done
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
