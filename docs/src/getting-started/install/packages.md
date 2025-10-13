[doc-caching]: ../../guides/caching.md
[doc-theming]: ../../guides/theming.md
[gh-nixpkgs]: https://github.com/nixos/nixpkgs
[gitkraken]: https://www.gitkraken.com/git-client
[hm-extraspecialargs]: https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-nixos-module
[hm-nixos-module]: https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
[hm-nixpkgs-overlay]: https://nix-community.github.io/home-manager/options.xhtml#opt-nixpkgs.overlays
[hm-standalone]: https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone
[hm-useglobalpkgs]: https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
[hm]: https://nix-community.github.io/home-manager
[nixos-manual]: https://nixos.org/manual/nixos/stable
[nixos-opt-nixpkgs-overlays]: https://search.nixos.org/options?channel=25.05&show=nixpkgs.overlays&query=nixpkgs.overlays&size=1
[nixos-wiki-flakes]: https://wiki.nixos.org/wiki/Flakes
[nixos-wiki-overlays]: https://wiki.nixos.org/wiki/Overlays
[nixpkgs-manual-overlays]: https://nixos.org/manual/nixpkgs/stable/#chap-overlays
[nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable

# Additional packages

NixKraken ships complementary packages which can be used alongside the [Home Manager][hm] module:

- `gitkraken`: [GitKraken][gitkraken] package used by the module
- `gitkraken-themes`: collection of bundled themes for GitKraken

## `gitkraken` package

This package distributes unmodified [GitKraken][gitkraken] versions from [nixpkgs][gh-nixpkgs] which are compatible with the [Home Manager][hm] module.

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

Internally, this package is used to cache GitKraken packages. See the [caching guide][doc-caching] for further details.

## `gitkraken-themes` packages collection

This is a collection of packages bundling various [GitKraken][gitkraken] themes which can be used with the relevant module options:

```nix
{
  programs.nixkraken = {
    enable = true;

    ui.extraThemes = with pkgs; [
      gitkraken-themes.catppuccin
    ];
  };
}
```

Please refer to the [theming guide][doc-theming] for further details on their usage.

## Installation

There are various ways to provide the packages to your configuration.

The examples below showcase both [overlays][nixpkgs-manual-overlays] and [Home Manager `extraSpecialArgs`][hm-extraspecialargs], but there might be other undocumented ways to make the packages available to your configuration.

Feel free to contribute additional ways to provide them!

### Overlays

> [!NOTE]
>
> The goal of this documentation is not to cover every possible way to define overlays, nor to explain how they work neither to provide best-practices or golden paths to their usage.
>
> Please refer to prior art available online. A good starting point is the [official wiki article][nixos-wiki-overlays].

#### Flakes

When creating the [nixpkgs][nixpkgs-manual] instance in your [Flake][nixos-wiki-flakes], define an overlay to:

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

Alternatively, [Home Manager's `nixpkgs.overlays` option][hm-nixpkgs-overlay] can be used to define the overlay, whether using [standalone Home Manager][hm-standalone] or [Home Manager integrated with NixOS][hm-nixos-module].

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
> When integrated with NixOS, if Home Manager's [`useGlobalPackages` option][hm-useglobalpkgs] is enabled, the overlay will not have any effect.
>
> In such case, the overlay **must** be defined in [NixOS configuration][nixos-manual], either from nixpkgs import, or using NixOS' [`nixpkgs.overlays` option][nixos-opt-nixpkgs-overlays] as shown in the next section.

#### NixOS

When [Home Manager is integrated with NixOS][hm-nixos-module], it is possible to define the overlay in NixOS configuration so that Home Manager inherits it.

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
