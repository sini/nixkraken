{ pkgs, ... }:

let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs = with pkgs; [
    coreutils
    jq
    openssl
    unixtools.column
  ];
}
