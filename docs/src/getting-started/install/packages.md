# Additional packages

NixKraken ships complementary packages which can be used alongside the Home Manager module:

- `gitkraken`: GitKraken package used by the module
- `gitkraken-themes`: collection of bundled themes for GitKraken

## `gitkraken` package

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

This package distributes unmodified GitKraken versions from [nixpkgs](https://github.com/nixos/nixpkgs) which are compatible with the Home Manager module.

By default, it tracks the latest version, but it can also be used to install prior GitKraken versions:

```nix
{
  home.packages = with pkgs; [
    # Latest supported version
    gitkraken

    # Specific version (supported by NixKraken)
    gitkraken.override { version = "11.3.0"; }
  ];
}
```

Internally, this package is used to cache GitKraken packages. See the [caching guide](../../guides/caching.md) for further details.

## `gitkraken-themes` packages collection

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

This is a collection of packages bundling various GitKraken themes which can be used with the relevant module options:

```nix
{
  programs.nixkraken = {
    enable = true;

    ui.extraThemes = with pkgs; [
      gitkraken-themes.catppuccin.mocha
    ];
  };
}
```

Please refer to the [theming guide](../../guides/theming.md) for further details on their usage.

## Installation

There are various ways to provide the packages to your configuration.

The examples below showcase both [overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays) and [Home Manager `extraSpecialArgs`](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-nixos-module), but there might be other undocumented ways to make the packages available to your configuration.

Feel free to contribute additional ways to provide them!

### Overlays

> [!NOTE]
>
> The goal of this documentation is not to cover every possible way to define overlays, nor to explain how they work neither to provide best-practices or golden paths to their usage.
>
> Please refer to prior art available online. A good starting point is the [official wiki article](https://wiki.nixos.org/wiki/Overlays).

#### Flakes

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

When creating the nixpkgs instance in your Flake, define an overlay to:

1. Replace `gitkraken` by NixKraken's one
2. Add the `gitkraken-themes` package

For example:

```nix
{
  # ...

  outputs = { self, nixpkgs, home-manager, nixkraken }:
    let
      system = "x86_64-linux";

      # 1. Define overlay
      nixkrakenOverlay = (final: prev: {
        inherit (nixkraken.packages.${final.system})
          gitkraken
          gitkraken-themes
          ;
      });

      # 2. Extend nixpkgs
      pkgs = nixpkgs.legacyPackages.${system}.extend nixkrakenOverlay;

      # ...or import nixpkgs and set the overlays attribute
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixkrakenOverlay ];
      };
    in
    {
      # ...
    };
}
```

#### Home Manager

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

Alternatively, [Home Manager's `nixpkgs.overlays` option](https://nix-community.github.io/home-manager/options.xhtml#opt-nixpkgs.overlays) can be used to define the overlay, whether using standalone Home Manager or Home Manager integrated with NixOS.

> [!NOTE]
>
> This would make the packages available only to the configuration the overlay is applied to.

```nix
# Standalone Home Manager configuration

homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
  modules = [
    {
      nixpkgs.overlays = [
        (final: prev: {
          inherit (nixkraken.packages.${final.system})
            gitkraken
            gitkraken-themes
            ;
        })
      ];
    }
  ];
};
```

```nix
# Home Manager integrated with NixOS

nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
  modules = [
    {
      home-manager.users."your-username" = {
        nixpkgs.overlays = [
          (final: prev: {
            inherit (nixkraken.packages.${final.system})
              gitkraken
              gitkraken-themes
              ;
          })
        ];
      };
    }
  ];
};
```

> [!WARNING]
>
> When integrated with NixOS, if Home Manager's [`useGlobalPackages` option](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module) is enabled, the overlay will not have any effect.
>
> In such case, the overlay **must** be defined in NixOS configuration, either from nixpkgs import, or using NixOS' [`nixpkgs.overlays` option]() as shown in the next section.

#### NixOS

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

When Home Manager is integrated with NixOS, it is possible to define the overlay in NixOS configuration so that Home Manager inherits it.

```nix
nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
  nixpkgs.overlays = [
    (final: prev: {
      inherit (nixkraken.packages.${final.system})
        gitkraken
        gitkraken-themes
        ;
    })
  ];
}
```

### `extraSpecialArgs`

![Tests](https://img.shields.io/badge/Tests-TODO-orange)

```nix
# Standalone Home Manager configuration

homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
  # 1. Add NixKraken packages in a special 'nixkraken' argument
  extraSpecialArgs = {
    nixkraken = nixkraken.packages.${system};
  };

  modules = [
    # 2. NixKraken packages are available from the 'nixkraken' module argument
    ({ nixkraken, ... }: {
      # ...
    })
  ];
};
```

```nix
# Home Manager integrated with NixOS

nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  modules = [
    {
      # 1. Add NixKraken packages in a special 'nixkraken' argument
      home-manager.extraSpecialArgs = {
        nixkraken = nixkraken.packages.${system};
      };
    }

    # 2. NixKraken packages are available in the 'nixkraken' module argument
    ({ nixkraken, ... }): {
      # ...
    }
  ];
};
```
