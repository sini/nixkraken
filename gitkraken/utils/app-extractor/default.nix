{
  pkgs ? import <nixpkgs> { },
  version ? null,
}:

let
  inherit (pkgs)
    callPackage
    runCommand
    asar
    nodePackages
    ;
  gitkraken = callPackage ../../. { inherit version; };
in
runCommand "extract-gitkraken-app"
  {
    buildInputs = [
      asar
      nodePackages.prettier
    ];
  }
  ''
    mkdir -p $out
    asar e ${gitkraken.src}/resources/app.asar "$out"
    prettier "$out/src/**/*.js" -w
  ''
