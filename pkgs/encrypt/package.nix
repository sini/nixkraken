{
  writeShellApplication,
  coreutils,
  jq,
  openssl,
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
    jq
    openssl
    unixtools.column
  ];
}
