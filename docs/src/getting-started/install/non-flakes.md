[gh-discuss]: https://github.com/nicolas-goudry/nixkraken/discussions/new?category=q-a
[gh-issues]: https://github.com/nicolas-goudry/nixkraken/issues
[gh-prs]: https://github.com/nicolas-goudry/nixkraken/pulls
[hm-config]: https://nix-community.github.io/home-manager/index.xhtml#ch-usage
[hm-install]: https://nix-community.github.io/home-manager/index.xhtml#ch-installation
[jq]: https://jqlang.org
[loc-retrieve-hash]: #retrieve-release-hash
[niv]: https://github.com/nmattia/niv
[nix-hash-new]: https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-hash-convert.html
[nix-hash]: https://nix.dev/manual/nix/stable/command-ref/nix-hash.html
[nix-manual-experimental-feat]: https://nix.dev/manual/nix/stable/contributing/experimental-features#xp-feature-nix-command
[nix-manual-fetchtarball]: https://nix.dev/manual/nix/stable/language/builtins.html#builtins-fetchTarball
[nix-prefetch-git]: https://search.nixos.org/packages?channel=25.05&show=nix-prefetch-git&query=nix-prefetch-git&size=1
[nix-prefetch-url]: https://nix.dev/manual/nix/stable/command-ref/nix-prefetch-url.html
[nixos-manual]: https://nixos.org/manual/nixos/stable
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[nixpkgs-manual-fetchers]: https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers
[nixpkgs-manual-fetchfromgh]: https://nixos.org/manual/nixpkgs/stable/#fetchfromgithub
[nixpkgs-manual-fetchgit]: https://nixos.org/manual/nixpkgs/stable/#fetchgit
[nixpkgs-manual-fetchzip]: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-fetchers-fetchzip
[nixpkgs-manual-src-hash]: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-fetchers-updating-source-hashes
[npins]: https://github.com/andir/npins

# Install without Flakes

There are various ways to use NixKraken without [Flakes][nixos-wiki-flakes], depending on whether you rely on builtin [Nix fetchers][nixpkgs-manual-fetchers] or a dedicated dependencies pinning tool.

> [!NOTE]
>
> Configuration code beyond those specific to NixKraken are provided as example only, your configuration may vary. Feel free to [open a discussion][gh-discuss] if you are stuck integrating NixKraken within your configuration.
>
> Refer to [Home Manager installation documentation][hm-install] as well as the [NixOS manual][nixos-manual] for further details on each of these.

## Recommended method: using `fetchFromGitHub`

The simplest way to use NixKraken without [Flakes][nixos-wiki-flakes] is to fetch it directly from GitHub inside your [Home Manager configuration][hm-config].

```nix
{ lib, pkgs, ... }:

let
  nixkraken = pkgs.fetchFromGitHub {
    owner = "nicolas-goudry";
    repo = "nixkraken";
    rev = "main";
    # rev = "<branch-name|commit-sha>";
    hash = lib.fakeHash; # Make sure to read the callout below
  };
in
{
  imports = [
    # Import the NixKraken module from the fetched source
    "${nixkraken}/module.nix"
  ];
}
```

_See also: [fetcher reference][nixpkgs-manual-fetchfromgh]_

> [!WARNING]
>
> **About `lib.fakeHash`**
>
> A common pattern in Nix is to [use a fake hash like `lib.fakeHash` or an empty string (`""`) as a placeholder][nixpkgs-manual-src-hash] to obtain a remote source hash.
>
> When the configuration is built, the evaluation will fail. But the error message will output the expected hash, which can then be copied back into the configuration.
>
> To get the hash without a failed evaluation, refer to the section on how to [retrieve the release hash][loc-retrieve-hash].

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
      hash = lib.fakeHash;
    }}/module.nix"
  ];
}
```

_See also: [fetcher reference][nixpkgs-manual-fetchzip]_

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
      hash = lib.fakeHash;
    }}/module.nix"
  ];
}
```

_See also: [fetcher reference][nixpkgs-manual-fetchgit]_

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
      sha256 = lib.fakeSha256;
    }}/module.nix"
  ];
}
```

_See also: [fetcher reference][nix-manual-fetchtarball]_

</details>

### Using pinning tools

#### [niv][niv]

```bash
niv add nicolas-goudry/nixkraken
# niv add nicolas-goudry/nixkraken -b <branch-name>
# niv add nicolas-goudry/nixkraken -r <commit-sha>
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
> These instructions are untested. Please [report an issue][gh-issues] if they are not working, or [send a PR][gh-prs] fixing them.

#### [npins][npins]

```bash
npins add github nicolas-goudry nixkraken
# npins add github -b <branch-name> nicolas-goudry nixkraken
# npins add github --at <commit-sha> nicolas-goudry nixkraken
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
> These instructions are untested. Please [report an issue][gh-issues] if they are not working, or [send a PR][gh-prs] fixing them.

## Retrieve release hash

Users willing to avoid using `lib.fakeHash` can retrieve the release hash using either [`nix-prefetch-git`][nix-prefetch-git] or [`nix-prefetch-url`][nix-prefetch-url], as shown below.

### `nix-prefetch-git`

The command below outputs various information about NixKraken sources.

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

Here, the relevant key is `hash`. Tools like [`jq`][jq] can be used to extract it directly from the JSON output of the command:

```bash
nix-prefetch-git \
  --url git@github.com:nicolas-goudry/nixkraken.git \
  --quiet \
| jq -r '.hash'
```

> 💡 **Tips**
>
> To retrieve the sources hash at a given point in history, use `--rev <commit-sha>`.
>
> To retrieve the sources hash for a given branch, use `--rev refs/heads/<branch-name>`.

### `nix-prefetch-url`

The commands below use [nix-prefetch-url][nix-prefetch-url] and either [nix-hash][nix-hash] or [Nix' `hash convert`][nix-hash-new] commands, depending on Nix [experimental feature][nix-manual-experimental-feat] being enabled.

nix-prefetch-url will download NixKraken source archive from GitHub into the store, extract it and compute its Nix base32 hash.

The hash is then handed to `nix-hash` / `nix hash convert` to get the final hash expected by fetchers.

```bash
# Using new Nix commands
nix hash convert \
  --hash-algo sha256 \
  --from nix32 \
  "$(nix-prefetch-url \
       --unpack "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz")"
```

```bash
# ...or classic Nix commands
nix-hash \
  --to-sri \
  --type sha256 \
  "$(nix-prefetch-url \
       --unpack "https://github.com/nicolas-goudry/nixkraken/archive/main.tar.gz")"
```

> 💡 **Tips**
>
> To retrieve the sources hash at a given point in history (branch or commit), replace `main.tar.gz` by `<branch-name|commit-sha>.tar.gz`.
