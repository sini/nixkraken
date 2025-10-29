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
  name = "gitkraken-config-discovery";
  text = ./script.sh;

  runtimeInputs = [
    coreutils
    deep-json-diff
    jq
    gitkraken
    inotify-tools
  ];
}
