# Install with Flakes

There are two primary ways to use NixKraken with Flakes, depending on whether the home environment is managed as part of a NixOS system or as a standalone configuration.

### Standalone Home Manager

Use this method if the user environment is managed with Home Manager on any OS (including NixOS, macOS, or other Linux distributions) through its own `flake.nix`.

Here is a complete, minimal `flake.nix` for a standalone setup:

```nix
{
  description = "Standalone Home Manager setup with NixKraken";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixkraken.url = "github:nicolas-goudry/nixkraken";
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

          # 2. Add configuration
          {
            programs.nixkraken.enable = true;
            # ... add other options here
          }
        ];
      };
    };
}
```

### Integrated with NixOS

Use this method if the user environment is managed directly within the NixOS system's `flake.nix`.

Here is a complete, minimal `flake.nix` for a NixOS setup:

```nix
{
  description = "NixOS system with NixKraken for a user";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixkraken.url = "github:nicolas-goudry/nixkraken";
  };

  outputs = { self, nixpkgs, home-manager, nixkraken }: {
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

          # Configure Home Manager for this user
          home-manager.users."your-username" = {
            imports = [
              # 1. Import the NixKraken module
              nixkraken.homeManagerModules.nixkraken
            ];

            # 2. Add configuration
            programs.nixkraken.enable = true;
            # ... add other options here
          };
        }
      ];
    };
  };
}
```
