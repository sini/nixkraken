{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

let
  themePath = "umbraco-dark.jsonc";
in
stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-umbraco-dark";
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
    cp Umbraco-Dark/${themePath} $out
    runHook postInstall
  '';

  passthru.default = themePath;

  meta = {
    description = "Umbraco Dark theme for GitKraken";
    homepage = "https://github.com/owainwilliams/gitkrakenthemes/tree/${version}/Umbraco-Dark";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
