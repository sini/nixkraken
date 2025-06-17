[gitkraken-nixpkgs]: https://github.com/nixos/nixpkgs/tree/master/pkgs/by-name/gi/gitkraken/package.nix

# Considerations

## Compatibility

Since GitKraken is a **proprietary** and **unfree** software, various aspects of this module's development rely on interacting with minified code that may change between releases. As a result, **compatibility cannot be guaranteed**, and the module is likely to break with each new GitKraken update.

## Stability

Development occurs on the `main` branch, which should be **considered unstable** and may not always be compatible with any particular GitKraken release.

When the module is confirmed to work with a specific GitKraken version, a tag matching that GitKraken version will be created (for example, if the module works with version 11.0.0, a new tag for 11.0.0 will be created - even if multiple tags may point to the same commit).

**Users seeking stability should use aforementioned versioned tags** rather than the `main` branch. There's also the `stable` tag, which dynamically tracks the latest working release.

## Velocity

**Breakages may occur** from time to time, potentially resulting in **missing features**, **incomplete configuration**, or **general incompatibility** between the module and the installed version of GitKraken.

As the main GitKraken maintainer on [nixpkgs][gitkraken-nixpkgs] and a daily GitKraken user, I strive to test the module with new versions and address issues as quickly as possible. Users are also encouraged to **report any issues** encountered when updating - or even better: to **contribute fixes**! Pull requests are always welcome 🙂

Finally, updates to this module are provided on a best-effort basis, in my free time. While every attempt will be made to keep the module compatible with the latest GitKraken release, there is no strict update schedule. Users should be prepared for occasional delays in compatibility following new GitKraken releases.

