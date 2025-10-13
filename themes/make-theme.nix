{
  lib,
  runCommand,
  name,
  src,
  path,
  meta,
  prettyName ? null,
}:

runCommand name
  {
    inherit meta src;

    passthru = {
      inherit prettyName;

      id = builtins.baseNameOf path;
    };
  }
  ''
    mkdir -p $out
    cp "$src/${path}" $out
  ''
