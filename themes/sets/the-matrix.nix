{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

let
  themePath = "matrix.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-the-matrix";
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
    cp TheMatrix/${themePath} $out
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "The Matrix theme for GitKraken";
    homepage = "https://github.com/owainwilliams/gitkrakenthemes/tree/${version}/TheMatrix";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
