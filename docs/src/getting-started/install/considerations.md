# Considerations

> [!IMPORTANT]
>
> The project is still in development. It's not _early stage_ per se, but still is not stable enough to be considered "production ready".
>
> Additionally, the branches and tags referenced inside this document may or may not exist at the time. This is expected.

## Compatibility

Since GitKraken is a **proprietary** and **unfree** software, various aspects of this module's development rely on interacting with minified code that may change between releases. As a result, **compatibility cannot be guaranteed**, and the module is likely to break with each new GitKraken update.

When the module is confirmed to work with a specific GitKraken version, a tag matching that GitKraken version will be created. This process means that multiple tags may point to the same commit. For example, if a given commit works with version 11.0.0 and 11.1.0, both tags `v11.0.0` and `v11.1.0` will target this commit.

## Stability

Development occurs on the `main` branch, which should be **considered unstable** and may not always be compatible with any particular GitKraken release.

**Users seeking stability should use aforementioned versioned tags** rather than the `main` branch. There's also the `stable` tag, which dynamically tracks the latest working release.

To use a specific version tag, modify the `flake.nix` inputs like this:

```nix
{
  # Use a specific version
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken/v11.1.0";

  # Or, to always get the latest stable version
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken/stable";
}
```

> [!NOTE]
>
> The examples above use [Nix Flakes](https://nixos.wiki/wiki/Flakes), please refer to the [non-Flake installation guide](./non-flakes.md) to learn how to use a specific version of NixKraken.

**Breakages may occur** from time to time, potentially resulting in **missing features**, **incomplete configuration**, or **general incompatibility** between the module and the installed version of GitKraken.

## Velocity

As the main GitKraken maintainer on [nixpkgs](https://github.com/nixos/nixpkgs/blob/master/pkgs/by-name/gi/gitkraken/package.nix) and a daily GitKraken user, I strive to test the module with new versions and address issues as quickly as possible. Users are also encouraged to **report any issues** encountered - or even better: to **contribute fixes**! Pull requests are always welcome 🙂

Finally, updates to this module are provided on a best-effort basis, in my free time. While every attempt will be made to keep the module compatible with the latest GitKraken release, there is no strict update schedule. Users should be prepared for occasional delays in compatibility following new GitKraken releases.
