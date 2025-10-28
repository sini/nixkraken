{
  stdenvNoCC,
  lib,
}:

let
  themePath = "celestial-dark.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-celestial-dark";
  version = "11.5.0";

  src = ./celestial-dark.jsonc;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp ${src} $out/${themePath}
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "Celestial Dark theme for GitKraken (hidden builtin)";
    homepage = "https://github.com/nicolas-goudry/nixkraken/tree/main/themes/sets/celestial-dark";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
