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
> @CACHED_COMMIT_LIST@
>
> </details>

## Non-NixOS users

### Declarative with Flakes

Users managing their configuration declaratively through a `flake.nix` can add the cache settings to the Flake's `nixConfig` attribute:

```nix
{
  description = "Declarative Nix configuration";

  nixConfig = {
    extra-substituters = "https://pub-8eca3a11aed542be899dfd21df917e06.r2.dev";
    extra-trusted-public-keys = "nixkraken-cache:hpaLSjsyPKPgITZzrdm9V+7eDDxYqC6eMw38Vo7cGcA=";
  };

  inputs = { /* ... */ };
  outputs = { /* ... */ };
}
```

### Imperative with `nix.conf`

Alternatively, the `nix.conf` file _(usually located at `/etc/nix/nix.conf`)_ can be imperatively edited to add the following configuration:

```plain
extra-substituters = https://pub-8eca3a11aed542be899dfd21df917e06.r2.dev
extra-trusted-public-keys = nixkraken-cache:hpaLSjsyPKPgITZzrdm9V+7eDDxYqC6eMw38Vo7cGcA=
```

## NixOS users

NixOS users can configure the Nix configuration file declaratively, using the following option in their system configuration:

```nix
{
  nix.extraOptions = ''
    extra-substituters = https://pub-8eca3a11aed542be899dfd21df917e06.r2.dev
    extra-trusted-public-keys = nixkraken-cache:hpaLSjsyPKPgITZzrdm9V+7eDDxYqC6eMw38Vo7cGcA=
  '';
}
```
