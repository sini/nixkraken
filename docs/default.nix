{
  stdenvNoCC,
  mdbook,
  mdbook-alerts,
  mdbook-pagetoc,
}:

stdenvNoCC.mkDerivation {
  name = "nixkraken-docs";
  src = ./.;

  nativeBuildInputs = [
    mdbook
    mdbook-alerts
    mdbook-pagetoc
  ];

  dontPatch = true;
  dontConfigure = true;
  doCheck = false;
  dontFixup = true;

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
