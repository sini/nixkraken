{
  lib,
  stdenv,
  callPackage,
  substitute,
  python3,
  xdg-utils,
}:

let
  decrypt = callPackage ../decrypt/package.nix { };
  encrypt = callPackage ../encrypt/package.nix { };
in
stdenv.mkDerivation rec {
  name = "gk-login";
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

  buildInputs = [
    decrypt
    encrypt
    xdg-utils
  ];
  propagatedBuildInputs = [
    (python3.withPackages (
      p: with p; [
        cryptography
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
    description = "Login to GitKraken from command line";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      nicolas-goudry
    ];
  };
}
