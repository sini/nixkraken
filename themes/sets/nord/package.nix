{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

let
  themePath = "nord-dark.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-nord";
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
    cp Themes/Nord/${themePath} $out
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "Nord theme for GitKraken";
    homepage = "https://github.com/jonbunator/gitkraken-custom-themes/tree/v${version}/Themes/Nord";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
