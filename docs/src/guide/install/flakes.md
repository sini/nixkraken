# Flakes

### Home Manager

This method uses Home Manager's `modules` attribute to make the `nixkraken` option available to a specific Home Manager configuration.

```nix
{
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken";

  outputs = { self, home-manager, nixkraken }: {
    homeConfigurations.your-hm-config = home-manager.lib.homeManagerConfiguration {
      modules = [
        nixkraken.homeManagerModules.nixkraken
      ];
    };
  };
}
```

### NixOS

This method uses Home Manager's `sharedModules` attribute to make the `nixkraken` option available to all Home Manager configurations.

```nix
{
  inputs.nixkraken.url = "github:nicolas-goudry/nixkraken";

  outputs = { self, nixpkgs, home-manager, nixkraken }: {
    nixosConfigurations.your-nixos-config = nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager {
          home-manager.sharedModules = [
            nixkraken.homeManagerModules.nixkraken
          ];
        }
      ];
    };
  };
}
```
