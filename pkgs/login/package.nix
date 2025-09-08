{
  callPackage,
  writeShellApplication,
  coreutils,
  jq,
  pigz,
  unixtools,
  xdg-utils,
}:

let
  name = builtins.baseNameOf (builtins.toString ./.);
  decrypt = callPackage ../decrypt/package.nix { };
  encrypt = callPackage ../encrypt/package.nix { };
in
writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs = [
    coreutils
    decrypt
    encrypt
    jq
    pigz
    unixtools.column
    xdg-utils
  ];
}
