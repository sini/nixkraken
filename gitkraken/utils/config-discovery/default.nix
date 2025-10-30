{
  pkgs ? import <nixpkgs> { },
  version ? null,
}:

let
  inherit (pkgs)
    writeShellApplication
    coreutils
    jq
    inotify-tools
    ;

  gitkraken = pkgs.callPackage ../../. { inherit version; };
  deep-json-diff = pkgs.callPackage ../deep-json-diff { };
in
writeShellApplication {
  name = "gk-config-discovery";
  text = ./script.sh;

  derivationArgs = {
    version = "1.0.0";
  };

  runtimeInputs = [
    coreutils
    deep-json-diff
    jq
    gitkraken
    inotify-tools
  ];
}
