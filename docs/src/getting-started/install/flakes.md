# Install with Flakes

Using [Flakes](https://nixos.wiki/wiki/Flakes), there are two primary ways to use the NixKraken module, depending on whether the home environment is managed as part of a NixOS system or as a standalone Home Manager configuration.

> [!NOTE]
>
> Configuration code beyond those specific to NixKraken are provided as example only, your configuration may vary. Feel free to [open a discussion](https://github.com/nicolas-goudry/nixkraken/discussions/new?category=q-a) if you are stuck integrating NixKraken within your configuration.
>
> Refer to [Home Manager installation documentation](https://nix-community.github.io/home-manager/index.xhtml#ch-installation) as well as the [NixOS manual](https://nixos.org/manual/nixos/stable/) for further details on each of these.

## Standalone Home Manager

Use this method if the user environment is managed with Home Manager on any OS (including NixOS, macOS, or other Linux distributions) through its own `flake.nix`.

Here is a complete, minimal `flake.nix` for a standalone setup:

```nix
{
  description = "Standalone Home Manager setup with NixKraken";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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
      # Home Manager configuration for 'your-username' user
      homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          # 1. Import the NixKraken module
          nixkraken.homeManagerModules.nixkraken

          # 2. Configure NixKraken
          {
            programs.nixkraken.enable = true;
            # ... add other options here
          }
        ];
      };
    };
}
```

## Integrated with NixOS

Use this method if the user environment is managed directly within the NixOS system's `flake.nix`.

Here is a complete, minimal `flake.nix` for a NixOS setup:

```nix
{
  description = "NixOS system with NixKraken for a user";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixkraken = {
      url = "github:nicolas-goudry/nixkraken";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixkraken }: {
    # NixOS configuration for 'your-hostname' host
    nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # Import the main Home Manager module for NixOS
        home-manager.nixosModules.home-manager

        # System configuration
        {
          users.users."your-username" = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

          # Home Manager configuration for 'your-username' user
          home-manager.users."your-username" = {
            # 1. Import the NixKraken module
            imports = [
              nixkraken.homeManagerModules.nixkraken
            ];

            # 2. Configure NixKraken
            programs.nixkraken.enable = true;
            # ... add other options here
          };
        }
      ];
    };
  };
}
```
