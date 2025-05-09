[gitkraken-nixpkgs]: https://github.com/nixos/nixpkgs/tree/master/pkgs/by-name/gi/gitkraken/package.nix
[gitkraken]: https://www.gitkraken.com
[home-manager]: https://nix-community.github.io/home-manager

# 🦑 nixkraken

![Home Manager](https://img.shields.io/badge/home%20manager-EC733B?style=for-the-badge)

Manage [GitKraken][gitkraken] configuration and profiles, the Nix way ❄️

## 🚨 Disclaimer

> [!IMPORTANT]
>
> This project is **not** affiliated with Axosoft (the makers of GitKraken) in any way.

## 📥 Installation

This module is meant to be used with [Home Manager][home-manager]. It can be installed through the following methods:

### Flakes: NixOS system-wide Home Manager configuration

```nix
{
  # Use unstable to get the latest updates (may break!)
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken";

  # Pin to a specific version
  #inputs.nixkraken.url = "github:nicolas-goudry/nixkraken/vX.Y.Z";

  outputs = { self, nixpkgs, home-manager, nixkraken }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      # Customize to your system
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.sharedModules = [
            inputs.nixkraken.homeManagerModules.nixkraken
          ];
        }
      ];
    };
  };
}
```

### Flakes: Configuration via `home.nix`

```nix
{ inputs, ... }:

{
  imports = [
    inputs.nixkraken.homeManagerModules.nixkraken
  ];
}
```

### `fetchTarball`: Configuration via `home.nix`

```nix
{ lib, ... }:

{
  imports = let
    # Replace this with an actual commit or tag
    rev = "<replace>";
  in [
    "${builtins.fetchTarball {
      url = "https://github.com/nicolas-goudry/nixkraken/archive/${rev}.tar.gz";
      # Replace this with an actual hash
      sha256 = lib.fakeHash;
    }}/module.nix"
  ];
}
```

## 🧩 Compatibility

Since GitKraken is a **proprietary** and **unfree** software, various aspects of this module's development rely on interacting with minified code that may change between releases. As a result, **compatibility cannot be guaranteed**, and the module is likely to break with each new GitKraken update.

Development occurs on the `main` branch, which should be considered unstable and may not always be compatible with any particular GitKraken release. When the module is confirmed to work with a specific GitKraken version, a tag matching that GitKraken version will be created (for example, if the module works with version 11.0.0, a new tag for 11.0.0 will be created - even if multiple tags may point to the same commit). Users seeking stability should use these versioned tags rather than the `main` branch.

Breakages may occur from time to time, potentially resulting in missing features, incomplete configuration, or general incompatibility between the module and the installed version of GitKraken. As the main GitKraken maintainer on [nixpkgs][gitkraken-nixpkgs] and a daily GitKraken user, I strive to test the module with new versions and address issues as quickly as possible. You are also encouraged to report any issues you encounter when updating - or even better: to contribute fixes! Pull requests are always welcome 🙂

Finally, updates to this module are provided on a best-effort basis, in my free time. While every attempt will be made to keep the module compatible with the latest GitKraken release, there is no strict update schedule. Users should be prepared for occasional delays in compatibility following new GitKraken releases.

## 📦 Packages

Nixkraken packages are Bash scripts bundled using Nix's `writeShellApplication`, which allows to define their runtime dependencies. This approach enables the scripts to be used as Nix packages while also being executable directly, provided all their dependencies are available in the shell environment.

Packages are exported by the [`default.nix`](./default.nix) file dynamically: adding a directory with a `default.nix` will automatically make a package (named after the directory) available for use.

> [!NOTE]
>
> When you enter a Nix development shell, the packages are available as their `gk-`-prefixed counterparts:
>
> ```sh
> nix develop
> gk-configure
> gk-decrypt
> gk-encrypt
> gk-login
> ```

### `configure`

This Bash script automates the creation and management of GitKraken's configuration files, especially in the context of a [Home Manager][home-manager] installation. While it's intended for use during Home Manager activation by the nixkraken module, it can also be used independently for testing.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The script **will** modify GitKraken's configuration files, and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

#### Usage

All options are documented in the script's help output:

```sh
./configure/script.sh --help
gk-configure --help
```

Since this script is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments.

### `encrypt` / `decrypt`

These Bash scripts are used to encrypt and decrypt GitKraken's `secFile`s, which contain sensitive data such as access tokens. They are primarily intended for use by the [`login`](./login/script.sh) script, but can also be used independently.

Although their execution is considered safe (since they only read the `secFile`s and output results to stdout), they are provided as-is, with no warranty.

#### Usage

All options are documented in the scripts' help output:

```sh
./decrypt/script.sh --help
gk-decrypt --help

./encrypt/script.sh --help
gk-encrypt --help
```

The script themselves are extensively documented through comments.

#### Encryption / Decryption methods

The encryption and decryption methods are adapted from GitKraken's original code, reimplemented using Unix tools. The reference implementation below is prettified from `main.bundle.js` with comments manually added:

```js
// Arguments:
// - I: path to secFile
// - re: appId
// - ne: input encoding
//
// External variables
// - le: path module
// - ae: crypto module
// - ce: logging library
// - se: seems to be a wrapper around fs module and fs-extra library
I.exports = (I, re, ne) => {
  const pe = re || "",
    Ee = ne || "aes256",
    ge = le.resolve(I),
    doCrypto = (I, re) => {
      ce("doing crypto: %s", re ? "decrypting" : "encrypting");
      const ne = re ? "binary" : "utf8",
        se = re ? ae.createDecipher(Ee, pe) : ae.createCipher(Ee, pe),
        le = [new Buffer(se.update(I, ne)), new Buffer(se.final())],
        ge = Buffer.concat(le);
      return ce("done doing crypto"), ge;
    };
  return {
    load: () => (
      ce("attempting to load"),
      Promise.resolve()
        .then(() => se.readFileAsync(ge))
        .then((I) => doCrypto(I, !0).toString())
        .then((I) => JSON.parse(I))
        .catch((I) => (ce("failed to load:"), ce(I), {}))
    ),
    save: (I) => (
      ce("attempting to save"),
      Promise.resolve()
        .then(() => se.ensureFileAsync(ge))
        .then(() => JSON.stringify(I, null, 2))
        .then((I) => doCrypto(I, !1))
        .then((I) => se.writeFileAsync(ge, I))
        .catch((I) => {
          throw (ce("failed to save:"), ce(I), I);
        })
    ),
  };
};
```

In summary, the secrets are JSON data encrypted with the `appId` as the passphrase.

### `login`

This Bash script enables you to log in to your GitKraken account from the command line, supporting multiple providers and GitKraken profiles. It securely handles OAuth tokens, updates the GitKraken configuration, and manages encrypted secrets for both global and profile-specific authentication.

> [!IMPORTANT]
>
> **WE ARE NOT RESPONSIBLE FOR NUKING YOUR CONFIGURATION.**
>
> The script **will** modify GitKraken's configuration file as well as secret files (global and profile-specific), and loss of configuration is a possible outcome, although we strive to make it as safe as possible.
>
> Please back up your configuration before use.

#### Usage

All options are documented in the script's help output:

```sh
./login/script.sh --help
gk-login --help
```

The script itself is extensively documented through comments.

### `theme`

This Bash script provides a command-line interface for a very basic management of GitKraken themes. It allows you to list available themes and install new ones by linking theme files into GitKraken's themes directory. While it's intended for use during Home Manager activation by the nixkraken module, it can also be used independently for testing.

Although its execution is considered safe, it is possible that theme files are overwritten, resulting in theme data loss. **Please back up your themes before use.**

#### Usage

All options are documented in the script's help output:

```sh
./theme/script.sh --help
gk-theme --help
```

Since this script is typically run during Home Manager activation, it respects the following environment variables:

- `DRY_RUN`: if set, commands are not executed, only logged
- `VERBOSE`: if set, logs are enabled

The script itself is extensively documented through comments.
