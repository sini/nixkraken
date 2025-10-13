{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

let
  themePath = "oled-dream.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-oled-dream";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jonbunator";
    repo = "gitkraken-custom-themes";
    rev = "v${version}";
    hash = "sha256-RCwitJ6HeFYJNsrc2lsVqAe1urfsi1RcxBYXXni6Fv0=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp "Themes/Oled Dream/${themePath}" $out
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "Oled Dream theme for GitKraken";
    homepage = "https://github.com/jonbunator/gitkraken-custom-themes/tree/v${version}/Themes/Oled%20Dream";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
