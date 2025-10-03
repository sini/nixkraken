# Compatibility

> [!CAUTION]
>
> This project is still in development. It's not _early stage_ per se, but still is not stable enough to be considered "production ready".
>
> Additionally, the Git references mentioned in this document may or may not exist at the time of reading. This **is** expected until we reach an initial stable release.

Since GitKraken is a **proprietary** and **unfree** software (to some extent), various aspects of this module's development rely on interacting with minified code that may change between releases. As a result, **compatibility cannot be guaranteed**, and the module is likely to break with each new GitKraken update.

When the module is confirmed to work with a specific GitKraken version, a release branch matching this version will be created (ie. branch `v11.1.0` is expected to be fully compatible with GitKraken 11.1.0). Although release branches will most likely be considered feature-complete once created and won't see any further development, they still could introduce backports from newer versions (where relevant) as well as bug fixes.

Additionally, users should be aware that **NixKraken will only actively support GitKraken versions present in current stable and unstable branches of nixpkgs**. For example, at the time of writing (Oct. 2025), [nixpkgs 25.05 has GitKraken 11.1.0](https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/gi/gitkraken/package.nix#L59), meaning that earlier versions will not be supported.

## Stability

Development occurs on the `main` branch, which should be **considered unstable** and incompatible with any version of GitKraken.

**Users seeking stability should use aforementioned release branches** rather than the `main` branch. There's also the `stable` branch, which dynamically tracks the latest working release. No development will occur on the `stable` branch and it will never introduce a feature or bug fix which is not available on the latest available release branch.

To use a specific release branch, modify `flake.nix`' inputs like this:

```nix
# Use a specific version
{
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken/v11.1.0";
}
```

```nix
# ...or always get the latest stable version
{
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken/stable";
}
```

> [!NOTE]
>
> The examples above use [Nix Flakes](https://nixos.wiki/wiki/Flakes), please refer to the [non-Flake installation guide](../getting-started/install/non-flakes.md) to learn how to use a specific version of NixKraken.

**Breakages may occur** from time to time, potentially resulting in **missing features**, **incomplete configuration**, or **general incompatibility** between the module and the installed version of GitKraken.

## Velocity

Although we strive to test NixKraken with new GitKraken versions and address issues as quickly as possible, updates are provided on a best-effort basis and there is no strict update schedule. Users should be prepared for occasional delays in compatibility following new GitKraken releases.

Users are also encouraged to **[report any issues](https://github.com/nicolas-goudry/nixkraken/issues)** encountered - or even better: to **contribute fixes**! Pull requests are always welcome 🙂
