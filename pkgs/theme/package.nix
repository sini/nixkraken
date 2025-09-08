{
  writeShellApplication,
  coreutils,
  unixtools,
}:

let
  name = builtins.baseNameOf (builtins.toString ./.);
in
writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs = [
    coreutils
    unixtools.column
  ];
}
