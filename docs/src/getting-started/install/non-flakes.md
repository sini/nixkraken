# Install without Flakes

## Recommended method: using `fetchFromGitHub`

The simplest way to use Nixkraken without Flakes is to fetch it directly from GitHub inside `home.nix`.

```nix
{ lib, pkgs, ... }:

{
  imports = [
    # Import the Nixkraken module from the fetched source (ie. "${fetcher}/module.nix")
    "${pkgs.fetchFromGitHub {
      owner = "nicolas-goudry";
      repo = "nixkraken";
      rev = "main";
      # rev = "<branch-name|commit-sha>";
      # tag = "<tag-name>"; # Use either `rev` or `tag`, not both!
      hash = lib.fakeHash; # Make sure to read the callout below
    }}/module.nix"
  ];
}
```

> [!WARNING]
>
> **About `lib.fakeHash`**
>
> A common pattern in Nix is to use a fake hash like `lib.fakeHash` or an empty string (`""`) as a placeholder.
>
> When the configuration is built, the evaluation will fail. But the error message will output the expected hash, which can then be copied back into the configuration.
>
> To get the hash without a failed evaluation, refer to the section on how to [retrieve the release hash](#retrieve-release-hash).

## Alternative methods

If other fetchers or a dependency pinning tool should be used, see the options below.

### Using other Nix fetchers

<details>

<summary><code>fetchzip</code></summary>

```nix
{ lib, pkgs, ... }:

{
  imports = [
    "${pkgs.fetchzip {
      url = "https://github.com/nicolas-goudry/nixkraken/archive/main.zip";
      # url = "https://github.com/nicolas-goudry/nixkraken/archive/<branch-name|commit-sha>.zip";
      # url = "https://github.com/nicolas-goudry/nixkraken/archive/refs/tags/<tag-name>.zip";
      hash = "<retrieved-hash>";
      # hash = lib.fakeHash;
    }}/module.nix"
  ];
}
```

</details>

<details>

<summary><code>fetchgit</code></summary>

```nix
{ lib, pkgs, ... }:

{
  imports = [
    "${pkgs.fetchgit {
      url = "https://github.com/nicolas-goudry/nixkraken.git";
      rev = "main";
      # rev = "<branch-name|commit-sha>";
      # tag = "<tag-name>"; # Use either `rev` or `tag`, not both!
      hash = "<retrieved-hash>";
      # hash = lib.fakeHash;
    }}/module.nix"
  ];
}
```

</details>

<details>

<summary><code>fetchTarball</code></summary>

```nix
{ lib, ... }:

{
  imports = [
    "${builtins.fetchTarball {
      url = "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz";
      # url = "https://github.com/nicolas-goudry/nixkraken/archive/<branch-name|commit-sha>.tar.gz";
      # url = "https://github.com/nicolas-goudry/nixkraken/archive/refs/tags/<tag-name>.tar.gz";
      sha256 = "<retrieved-hash>";
      # sha256 = lib.fakeSha256;
    }}/module.nix"
  ];
}
```

</details>

### Using pinning tools

#### [niv](https://github.com/nmattia/niv)

```bash
niv add nicolas-goudry/nixkraken
```

```nix
let
  sources = import ./nix/sources.nix;
in {
  imports = [
    sources.nixkraken + "/module.nix"
  ];
}
```

> [!CAUTION]
> These instructions are untested. Please report an issue if they are not working, or suggest a PR fixing them.

#### [npins](https://github.com/andir/npins)

```bash
npins add github nicolas-goudry nixkraken
```

```nix
let
  sources = import ./npins;
in {
  imports = [
    sources.nixkraken + "/module.nix"
  ];
}
```

> [!CAUTION]
> These instructions are untested. Please report an issue if they are not working, or suggest a PR fixing them.

## Retrieve release hash

Users willing to avoid using `lib.fakeHash` can retrieve the release hash using either [`nix-prefetch-git`](#nix-prefetch-git) or [`nix-prefetch-url`](#nix-prefetch-url), as shown below.

### `nix-prefetch-git`

The command below outputs various information about Nixkraken sources.

```bash
nix-prefetch-git --url git@github.com:nicolas-goudry/nixkraken.git --quiet
```

```json
// Example response
{
  "url": "git@github.com:nicolas-goudry/nixkraken.git",
  "rev": "812365dfd82571d82751b192c90d3d6eca16d04c",
  "date": "2025-06-17T15:40:02+02:00",
  "path": "/nix/store/v42lgzcdygj8nyj193vrysi8il0aj8a5-nixkraken",
  "sha256": "1cpvfzdb7m16pj5ykj9dppyr1rm1gnzvhyb5qvvmg5ihbmqx6cgh",
  "hash": "sha256-8DHTcV0wllf3xmV5uL99oeaQ/b0tyemLvCbUs9p3+7I=",
  "fetchLFS": false,
  "fetchSubmodules": false,
  "deepClone": false,
  "leaveDotGit": false
}
```

Here, the relevant key is `hash`. Tools like [`jq`](https://jqlang.org/) can be used to extract it directly from the JSON output of the command:

```bash
nix-prefetch-git \
  --url git@github.com:nicolas-goudry/nixkraken.git \
  --quiet \
| jq -r '.hash'
```

> 💡 **Tips**
>
> To retrieve the sources hash at a given point in history (tag or commit), use `--rev <tag-name|commit-sha>`.
>
> To retrieve the sources hash for a given branch, use `--rev refs/heads/<branch-name>`.

### `nix-prefetch-url`

The following commands use `nix-prefetch-url` to get the Nix base32 hash from the unpacked sources archive retrieved from GitHub. The hash is then handed to `nix-hash` (or `nix hash convert`, which requires the `nix-command` [experimental feature](https://nix.dev/manual/nix/2.18/contributing/experimental-features#xp-feature-nix-command) to be enabled) to get the final hash expected by fetchers.

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

> 💡 **Tips**
>
> To retrieve the sources hash at a given tag, replace `main.tar.gz` by `refs/tags/<tag-name>.tar.gz`.
>
> To retrieve the sources hash at a given point in history (branch or commit), replace `main.tar.gz` by `<branch-name|commit-sha>.tar.gz`.
