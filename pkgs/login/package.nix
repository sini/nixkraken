{
  lib,
  stdenv,
  callPackage,
  substitute,
  installShellFiles,
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

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    decrypt
    encrypt
    xdg-utils
  ];

  propagatedBuildInputs = [
    (python3.withPackages (
      p: with p; [
        termcolor
      ]
    ))
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${src} $out/bin/${name}

    runHook postInstall
  '';

  postFixup = ''
    installShellCompletion --cmd ${name} \
      --bash <($out/bin/${name} --generate-completion bash) \
      --fish <($out/bin/${name} --generate-completion fish) \
      --zsh <($out/bin/${name} --generate-completion zsh)
  '';

  meta = {
    description = "Login to GitKraken from command line";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      nicolas-goudry
    ];
  };
}
