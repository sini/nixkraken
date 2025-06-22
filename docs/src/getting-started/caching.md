# Binary cache

As explained in the [caveats section](./caveats.md#long-installation-time), because GitKraken is an unfree package, its builds will not be cached in the default Nix cache (cache.nixos.org). This is expected and is clearly [documented in nixpkgs documentation](https://nixos.org/manual/nixpkgs/stable/#lib.licenses.unfree-unfree).

For this reason, Nixkraken has a dedicated [Cachix](https://cachix.org) cache for GitKraken builds. The cache is populated using a [GitHub Action](https://github.com/nicolas-goudry/nixkraken/blob/main/.github/workflows/gitkraken-cachix.yml) which uses the nixpkgs repository pinned at various commits to build and push the evaluated builds to Cachix.

Thanks to this cache, installing GitKraken is faster than ever. Find below several methods to enable this cache.

> [!WARNING]
> Users which want to use the [`programs.nixkraken.package`](../options/nixkraken.md#package) option cannot benefit from the Nixkraken cache unless they use one of the specific nixpkgs commits being cached.

## Non-NixOS users

For users which use Home Manager without NixOS, the following configuration should be added to the `nix.conf` file _(usually located at `/etc/nix/nix.conf`)_:

```plain
substituters = https://nixkraken.cachix.org
trusted-public-keys = nixkraken.cachix.org-1:sR/opxxCkFpC7eaDPuQBmRPyD7d2X05xZiL2ZJxhyLQ=
```

## NixOS users

NixOS users can configure their Nix configuration file declaratively using the following options in their system configuration:

```nix
{
  nix = {
    settings = {
      substituters = [
        "https://nixkraken.cachix.org"
      ];
      trusted-public-keys = [
        "nixkraken.cachix.org-1:sR/opxxCkFpC7eaDPuQBmRPyD7d2X05xZiL2ZJxhyLQ="
      ];
    };
  };
}
```
