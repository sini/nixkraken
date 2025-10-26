{
  lib,
  stdenv,
  substitute,
  python3,
}:

stdenv.mkDerivation rec {
  name = "gk-theme";
  version = "1.0.0";

  src = substitute {
    src = ./script.py;

    substitutions = [
      "--replace-fail"
      "@version@"
      version
      "--replace-fail"
      "@description@"
      meta.description
    ];
  };
  dontUnpack = true;

  propagatedBuildInputs = [
    (python3.withPackages (
      p: with p; [
        json5
        termcolor
      ]
    ))
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${src} $out/bin/${name}

    runHook postInstall
  '';

  meta = {
    mainProgram = name;
    description = "GitKraken themes handler";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      nicolas-goudry
    ];
  };
}
