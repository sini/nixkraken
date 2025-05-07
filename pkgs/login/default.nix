{
  pkgs,
  self,
  system,
  ...
}:

let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs =
    [
      self.packages.${system}.decrypt
      self.packages.${system}.encrypt
    ]
    ++ (with pkgs; [
      coreutils
      jq
      pigz
      unixtools.column
      xdg-utils
    ]);
}
