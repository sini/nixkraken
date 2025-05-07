{ pkgs, ... }@args:

let
  name = builtins.baseNameOf (builtins.toString ./.);
  decrypt = import ../decrypt args;
  encrypt = import ../encrypt args;
in
pkgs.writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs =
    [
      decrypt
      encrypt
    ]
    ++ (with pkgs; [
      coreutils
      jq
      pigz
      unixtools.column
      xdg-utils
    ]);
}
