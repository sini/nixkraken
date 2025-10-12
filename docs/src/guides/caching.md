[doc-opt-pkg]: ../options/nixkraken.md#package
[garnix]: https://garnix.io
[gitkraken]: https://www.gitkraken.com/git-client
[nix-cache]: https://cache.nixos.org
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[nixpkgs-manual-unfree]: https://nixos.org/manual/nixpkgs/stable/#lib.licenses.unfree-unfree

# Binary cache

Because [GitKraken][gitkraken] is an unfree package, its builds will not be cached in the [default Nix cache][nix-cache] (cache.nixos.org). This is expected and _somewhat_ [documented in nixpkgs manual][nixpkgs-manual-unfree].

For this reason, NixKraken is using [Garnix][garnix]' public free cache for GitKraken builds, with permission from GitKraken:

![Screenshot of support email allowing caching of GitKraken](./assets/caching-permission-proof.png 'Screenshot of support email allowing caching of GitKraken')

The cache is populated using Garnix' GitHub integration and uses dedicated [Flake][nixos-wiki-flakes] outputs to build and push the evaluated builds to the cache.

By using this cache, installing GitKraken is faster than ever. **A huge thanks to Garnix!**

> [!WARNING]
> Users who wish to use the [`programs.nixkraken.package`][doc-opt-pkg] option cannot benefit from the cache unless they use one of the commits listed below.
>
> <details><summary>List of cached commits</summary>
>
> @CACHED_COMMIT_LIST@
>
> </details>

## NixOS users

NixOS users can configure the cache by editing the Nix configuration file declaratively, using the following option in their system configuration:

```nix
{
  nix.extraOptions = ''
    extra-substituters = https://cache.garnix.io
    extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
  '';
}
```

## Non-NixOS users

### Declarative with Flakes

Users managing their configuration declaratively through a `flake.nix` can add the cache settings to the Flake's `nixConfig` attribute:

```nix
{
  description = "Declarative Nix configuration";

  nixConfig = {
    extra-substituters = "https://cache.garnix.io";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = { /* ... */ };
  outputs = { /* ... */ };
}
```

### Imperative with `nix.conf`

Alternatively, the `nix.conf` file _(usually located at `/etc/nix/nix.conf`)_ can be imperatively edited to define the cache settings:

```txt
extra-substituters = https://cache.garnix.io
extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
```
