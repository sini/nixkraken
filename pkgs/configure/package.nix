{
  writeShellApplication,
  coreutils,
  gawk,
  gnugrep,
  iproute2,
  jq,
  openssl,
  unixtools,
  util-linux,
}:

let
  name = builtins.baseNameOf (builtins.toString ./.);
in
writeShellApplication {
  name = "gk-${name}";
  text = builtins.readFile ./script.sh;

  runtimeInputs = [
    coreutils
    gawk
    gnugrep
    iproute2
    jq
    openssl
    unixtools.column
    util-linux
  ];
}
