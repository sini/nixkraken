{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

let
  themePath = "matcha.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-matcha-dark-sea";
  version = "8.3.0";

  src = fetchFromGitHub {
    owner = "owainwilliams";
    repo = "gitkrakenthemes";
    rev = version;
    hash = "sha256-W65IkaerLBpWWUvYtfr/ESKVTvWyqXWwgcVJaiU9aW4=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp Matcha-Dark-Sea/${themePath} $out
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "Matcha Dark Sea theme for GitKraken";
    homepage = "https://github.com/owainwilliams/gitkrakenthemes/tree/${version}/Matcha-Dark-Sea";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
