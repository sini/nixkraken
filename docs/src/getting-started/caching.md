# Binary cache

As explained in the [caveats section](./caveats.md#long-installation-time), because GitKraken is an unfree package, its builds will not be cached in the default Nix cache (cache.nixos.org). This is expected and _somewhat_ [documented in nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#lib.licenses.unfree-unfree).

For this reason, Nixkraken has a dedicated S3 cache for GitKraken builds. The cache is populated using a [GitHub Action](https://github.com/nicolas-goudry/nixkraken/blob/main/.github/workflows/cache-gitkraken.yml) which uses the nixpkgs repository pinned at various commits to build and push the evaluated builds to the cache.

Thanks to this cache, installing GitKraken is faster than ever. Find below several methods to enable this cache.

> [!CAUTION]
> The cache is currently hosted on Cloudflare R2 Object storage and exposed publicly using a [public development URL](https://developers.cloudflare.com/r2/buckets/public-buckets/#public-development-url).
>
> This means that access is rate limited and users might experience issues like HTTP 429 responses (too many requests). **Please do not report such issues on GitHub.**
>
> We are currently waiting for a reply from GitKraken's legal team before considering buying a dedicated domain name for the documentation and the cache.

> [!WARNING]
> Users who wish to use the [`programs.nixkraken.package`](../options/nixkraken.md#package) option cannot benefit from the cache unless they use one of the nixpkgs commits listed below.
>
> <details><summary>List of cached commits</summary>
>
> - GitKraken v11.2.0: [`e861cf9b42ab0d556989528b8997eb0992844180`](https://github.com/nixos/nixpkgs/blob/e861cf9b42ab0d556989528b8997eb0992844180)
> - GitKraken v11.1.1: [`5017262d69299951c156042e7f64ba63760204c2`](https://github.com/nixos/nixpkgs/blob/5017262d69299951c156042e7f64ba63760204c2)
> - GitKraken v11.1.0: [`36dcda8c3ea1c6bd23770b711326625712460ba3`](https://github.com/nixos/nixpkgs/blob/36dcda8c3ea1c6bd23770b711326625712460ba3)
> - GitKraken v11.0.0: [`37290199a6648a1e501839e07f6f9be95e4c58cc`](https://github.com/nixos/nixpkgs/blob/37290199a6648a1e501839e07f6f9be95e4c58cc)
> - GitKraken v10.8.0: [`fd85e9405d38b57996a9f6caf4b12839a1e5642e`](https://github.com/nixos/nixpkgs/blob/fd85e9405d38b57996a9f6caf4b12839a1e5642e)
> - GitKraken v10.7.0: [`17f5c2876228563a2029c7a20bc279b612dd3587`](https://github.com/nixos/nixpkgs/blob/17f5c2876228563a2029c7a20bc279b612dd3587)
> - GitKraken v10.6.3: [`355f34d1529edce864a3b4f5be6e312f72383348`](https://github.com/nixos/nixpkgs/blob/355f34d1529edce864a3b4f5be6e312f72383348)
> - GitKraken v10.6.2: [`381484d4652d91195ea0e5d5c509fb48564600ec`](https://github.com/nixos/nixpkgs/blob/381484d4652d91195ea0e5d5c509fb48564600ec)
> - GitKraken v10.6.1: [`e1a3a64af950591b0e1fc019fefb100963053790`](https://github.com/nixos/nixpkgs/blob/e1a3a64af950591b0e1fc019fefb100963053790)
> - GitKraken v10.6.0: [`480f1aa89744a656fcf4672d927c097bf3f39207`](https://github.com/nixos/nixpkgs/blob/480f1aa89744a656fcf4672d927c097bf3f39207)
> - GitKraken v10.5.0: [`6bb61e56d5616474a47675adbaa39e777fc901f1`](https://github.com/nixos/nixpkgs/blob/6bb61e56d5616474a47675adbaa39e777fc901f1)
> - GitKraken v10.4.1: [`fd5b39ad6e9ea714c41897e707b100b67137c1fa`](https://github.com/nixos/nixpkgs/blob/fd5b39ad6e9ea714c41897e707b100b67137c1fa)
>
> </details>

## Non-NixOS users

For users which use Home Manager without NixOS, the following configuration should be added to the `nix.conf` file _(usually located at `/etc/nix/nix.conf`)_:

```
extra-substituters = https://pub-8eca3a11aed542be899dfd21df917e06.r2.dev
extra-trusted-public-keys = nixkraken-cache:hpaLSjsyPKPgITZzrdm9V+7eDDxYqC6eMw38Vo7cGcA=
```

## NixOS users

NixOS users can configure their Nix configuration file declaratively using the following options in their system configuration:

```nix
{
  nix = {
    settings = {
      substituters = [
        "https://pub-8eca3a11aed542be899dfd21df917e06.r2.dev"
      ];
      trusted-public-keys = [
        "nixkraken-cache:hpaLSjsyPKPgITZzrdm9V+7eDDxYqC6eMw38Vo7cGcA="
      ];
    };
  };
}
```
