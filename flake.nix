{
  description = "GitKraken configuration and profiles, the Nix way";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      # nix flake check
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      # nix fmt
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # Export packages to allow usage of self packages in other packages
      # See ./pkgs/login/default.nix for usage example
      packages = eachSystem (
        pkgs:
        import ./pkgs {
          inherit (pkgs) lib;
          inherit pkgs;
          inherit self;
        }
      );

      # Development environment with packages used by the module available in PATH
      devShells = eachSystem (pkgs: {
        default = pkgs.callPackage ./shell.nix { inherit self; };
      });
    };
}
