{
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
    };
  }
  ''
    mkdir -p $out
    cp "$src/${path}" $out/theme.jsonc
  ''
