{
  lib,
  stdenv,
  python3,
}:

stdenv.mkDerivation rec {
  name = "deep-json-diff";
  version = "1.0.0";

  src = ./script.py;
  dontUnpack = true;

  propagatedBuildInputs = [
    python3
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${src} $out/bin/${name}

    runHook postInstall
  '';

  meta = {
    mainProgram = name;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      nicolas-goudry
    ];
  };
}
