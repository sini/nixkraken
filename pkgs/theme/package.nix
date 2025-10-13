{
  writeShellApplication,
  coreutils,
  unixtools,
  python313Packages,
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
    python313Packages.demjson3
  ];
}
