# Quick Start

This guide showcases a basic, working NixKraken configuration using [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [nixpkgs](https://github.com/nixos/nixpkgs)/[Home Manager](https://github.com/nix-community/home-manager) 25.05 on an x86-64 Linux host.

> [!NOTE]
> Not using Flakes? Follow our [non-Flake installation guide](./install/non-flakes.md) instead.

## 1. Create `flake.nix`

Use the following content, which sets GitKraken username and email.

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

_For other installation methods, see the [installation](./install/index.md) section._

## Next steps

**Get to know NixKraken**

- Learn by [example](./examples.md) for a quick overview of common use cases
- Read the [reference](../options/nixkraken.md) for a complete picture
- Understand [caveats](../notes/caveats.md) about known issues and limitations
- Check the [compatibility](../notes/compatibility.md) notice

**Explore advanced configuration**

- Setup the [binary cache](../guides/caching.md) for faster builds
- Manage multiple [profiles](../guides/profiles.md) like a pro
- Make GitKraken your own with [themes](../guides/theming.md)

**Get involved**

- [Contribute](../dev/contributing.md) to NixKraken, _it is fun!_
- Report bugs or request features on [GitHub](https://github.com/nicolas-goudry/nixkraken)
- Suggest new [ideas](https://github.com/nicolas-goudry/nixkraken/discussions/categories/ideas) to improve the project
