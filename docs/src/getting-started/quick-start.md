# Quick Start

> [!NOTE]
> Not using Flakes? Follow our [non-Flake installation guide](./install/non-flakes.md) instead.

This guide showcases a basic, working NixKraken configuration using [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [nixpkgs](https://github.com/nixos/nixpkgs)/[Home Manager](https://github.com/nix-community/home-manager) 25.05 on an x86-64 Linux host.

1. **Create a `flake.nix` file** with the following content, which sets GitKraken username and email

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

2. **Build and activate the configuration** by running the command below in the same directory as `flake.nix`

```bash
home-manager switch --flake '.#your-username'
```

🎉 **That's it!** GitKraken will now be configured with the given name and email.

_For more advanced options and non-Flake installation, see the [installation](./install/index.md) section._
