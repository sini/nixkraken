[jq]: https://jqlang.org/
[nix-command-experimental-feature]: https://nix.dev/manual/nix/2.18/contributing/experimental-features#xp-feature-nix-command

# Non-Flakes

## 1. Retrieve the release hash

Before fetching Nixkraken into the configuration, the hash of its sources should be retrieved.

There are several ways to do that, two of them being advertised below. However, it is also possible (and very common) to just use one of the fake hash methods listed below, attempt to build and get the expected hash from the resulting error message.

Fake hash methods:

- empty string `""`
- `lib.fakeHash`
- `lib.fakeSha256`
- `lib.fakeSha512`

### `nix-prefetch-git`

The command below outputs various information about Nixkraken sources. Here, the relevant key is `hash`. Tools like [`jq`][jq] can be used to extract it directly from the JSON output of the command.

```bash
nix-prefetch-git --url git@github.com:nicolas-goudry/nixkraken.git --quiet
```

To retrieve the sources hash at a given point in history (tag or commit), use `--rev <tag-name|commit-sha>`. \
To retrieve the sources hash for a given branch, use `--rev refs/heads/<branch-name>`.

### `nix-prefetch-url`

The following commands use `nix-prefetch-url` to get the Nix base32 hash from the unpacked sources archive retrieved from GitHub. The hash is then handed to `nix-hash` (or `nix hash convert`, which requires the `nix-command` [experimental feature][nix-command-experimental-feature] to be enabled) to get the final hash expected by fetchers.

```bash
nix-hash \
  --to-sri \
  --type sha256 \
  "$(nix-prefetch-url \
       --unpack "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz")"

# ...or using new nix commands
nix hash convert \
  --hash-algo sha256 \
  --from nix32 \
  "$(nix-prefetch-url \
       --unpack "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz")"
```

To retrieve the sources hash at a given tag, replace `main.tar.gz` by `refs/tags/<tag-name>.tar.gz`. \
To retrieve the sources hash at a given point in history (branch or commit), replace `main.tar.gz` by `<branch-name|commit-sha>.tar.gz`.

## 2. Fetch sources in configuration

Once the sources hash has been computed, or a fake hash will be used, a variety of fetchers can be used to actually fetch Nixkraken sources into your configuration.

The fetchers are listed below in **order of preferences**.

> [!WARNING]
> All `imports` attributes below are assigned the result of the `lib.singleton` lambda, which generates a list consisting of a single element passed as argument.
>
> It is very likely this lambda is not needed in the final configuration. Furthermore, chances are an `imports` attribute already exists in the configuration, in such case just add the new element to it.

### `fetchFromGitHub`

```nix
{ lib, pkgs, ... }:

{
  imports = lib.singleton "${pkgs.fetchFromGitHub {
    owner = "nicolas-goudry";
    repo = "nixkraken";
    rev = "main";
    # rev = "<branch-name|commit-sha>";
    # tag = "<tag-name>"; # Use either `rev` or `tag`, not both!
    hash = "<retrieved-hash>";
    # hash = lib.fakeHash;
  }}/module.nix";
}
```

### `fetchzip`

```nix
{ lib, pkgs, ... }:

{
  imports = lib.singleton "${pkgs.fetchzip {
    url = "https://github.com/nicolas-goudry/nixkraken/archive/main.zip";
    # url = "https://github.com/nicolas-goudry/nixkraken/archive/<branch-name|commit-sha>.zip";
    # url = "https://github.com/nicolas-goudry/nixkraken/archive/refs/tags/<tag-name>.zip";
    hash = "<retrieved-hash>";
    # hash = lib.fakeHash;
  }}/module.nix";
}
```

### `fetchgit`

```nix
{ lib, pkgs, ... }:

{
  imports = lib.singleton "${pkgs.fetchgit {
    url = "https://github.com/nicolas-goudry/nixkraken.git";
    rev = "main";
    # rev = "<branch-name|commit-sha>";
    # tag = "<tag-name>"; # Use either `rev` or `tag`, not both!
    hash = "<retrieved-hash>";
    # hash = lib.fakeHash;
  }}/module.nix";
}
```

### `fetchTarball`

```nix
{ lib, ... }:

{
  imports = lib.singleton "${builtins.fetchTarball {
    url = "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz";
    # url = "https://github.com/nicolas-goudry/nixkraken/archive/<branch-name|commit-sha>.tar.gz";
    # url = "https://github.com/nicolas-goudry/nixkraken/archive/refs/tags/<tag-name>.tar.gz";
    sha256 = "<retrieved-hash>";
    # sha256 = lib.fakeSha256;
  }}/module.nix";
}
```
