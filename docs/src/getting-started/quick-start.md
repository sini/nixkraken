[doc-caching]: ../guides/caching.md
[doc-caveats]: ../notes/caveats.md
[doc-compat]: ../notes/compatibility.md
[doc-contrib]: ../dev/contributing.md
[doc-examples]: ./examples.md
[doc-install]: ./install/index.md
[doc-nonflake]: ./install/non-flakes.md
[doc-opts]: ../options/nixkraken.md
[doc-profiles]: ../guides/profiles.md
[doc-theming]: ../guides/theming.md
[gh-discuss-ideas]: https://github.com/nicolas-goudry/nixkraken/discussions/categories/ideas
[gitkraken]: https://www.gitkraken.com/git-client
[hm]: https://nix-community.github.io/home-manager
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[repo]: https://github.com/nicolas-goudry/nixkraken

# Quick Start

This guide showcases a basic, working NixKraken configuration using [Nix Flakes][nixos-wiki-flakes] and [Home Manager][hm] 25.05 on an x86-64 Linux host.

> [!NOTE]
> Not using Flakes? Follow our [non-Flake installation guide][doc-nonflake] instead.

## 1. Create `flake.nix`

Use the following content, which sets [GitKraken][gitkraken]'s username and email.

```nix
{
  description = "A basic NixKraken setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixkraken = {
      url = "github:nicolas-goudry/nixkraken";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixkraken }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          # 1. Import the NixKraken module
          nixkraken.homeManagerModules.nixkraken

          # 2. Configure NixKraken
          {
            programs.nixkraken = {
              enable = true;

              user = {
                name = "Your Name";
                email = "your.email@example.com";
              };
            };
          }
        ];
      };
    };
}
```

## 2. Build and activate configuration

Run the command below in the same directory as `flake.nix`:

```bash
home-manager switch --flake '.#your-username'
```

🎉 **That is it!** GitKraken will now be configured with the given name and email.

_For other installation methods, see the [installation][doc-install] section._

## Next steps

**Get to know NixKraken**

- Learn by [example][doc-examples] for a quick overview of common use cases
- Read the [reference][doc-opts] for a complete picture
- Understand [caveats][doc-caveats] about known issues and limitations
- Check the [compatibility][doc-compat] notice

**Explore advanced configuration**

- Setup the [binary cache][doc-caching] for faster builds
- Manage multiple [profiles][doc-profiles] like a pro
- Make GitKraken your own with [themes][doc-theming]

**Get involved**

- [Contribute][doc-contrib] to NixKraken, _it is fun!_
- Report bugs or request features on [GitHub][repo]
- Suggest new [ideas][gh-discuss-ideas] to improve the project
