{
  pkgs ? import <nixpkgs> { },
  version ? null,
}:

let
  inherit (pkgs) callPackage runCommand;

  gitkraken = callPackage ./. { inherit version; };
in
runCommand "extract-gitkraken-app"
  {
    buildInputs = [
      pkgs.asar
      pkgs.nodePackages.prettier
      gitkraken
    ];
  }
  ''
    mkdir $out
    asar e ${gitkraken.src}/resources/app.asar $out
    prettier -w $out/src/main/static/main.bundle.js
  ''
