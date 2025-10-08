{
  lib,
  runCommand,
  fetchFromGitHub,
  name,
  src,
  path,
  meta,
  fetcher ? fetchFromGitHub,
  prettyName ? null,
}:

runCommand name
  {
    inherit meta;

    src = fetcher src;

    passthru = {
      inherit prettyName;

      id = lib.removeSuffix ".jsonc" (builtins.baseNameOf path);
    };
  }
  ''
    mkdir -p $out
    cp "$src/${path}" $out
  ''
