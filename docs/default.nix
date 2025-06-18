{
  lib,
  stdenvNoCC,
  nixosOptionsDoc,
  mdbook,
  mdbook-alerts,
  mdbook-pagetoc,
  nodejs,
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
in
stdenvNoCC.mkDerivation {
  name = "nixkraken-docs";
  src = ./.;

  nativeBuildInputs = [
    nodejs
    mdbook
    mdbook-alerts
    mdbook-pagetoc
  ];

  dontPatch = true;
  dontConfigure = true;
  doCheck = false;
  dontFixup = true;

  preBuild = ''
    node build-doc.js ${optionsDoc.optionsJSON}/share/doc/nixos/options.json
  '';

  buildPhase = ''
    runHook preBuild

    mdbook build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv book $out

    runHook postInstall
  '';
}
