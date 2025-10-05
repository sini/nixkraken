{
  runCommand,
  fetchFromGitHub,
  name,
  src,
  path,
  meta,
  fetcher ? fetchFromGitHub,
}:

runCommand name
  {
    inherit meta;

    src = fetcher src;
  }
  ''
    mkdir -p $out
    cp "$src/${path}" $out/theme.jsonc
  ''
