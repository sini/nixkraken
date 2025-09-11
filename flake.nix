{
  description = "GitKraken configuration and profiles, the Nix way";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      homeManagerModules.nixkraken = ./module.nix;

      # nix flake check
      checks = eachSystem (
        pkgs:
        let
          checks = {
            formatting = treefmtEval.${pkgs.system}.config.build.check self;
          };
        in
        checks
        // {
          all = pkgs.runCommand "all-checks" { buildInputs = builtins.attrValues checks; } "touch $out";
        }
      );

      # nix fmt
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # Packages
      packages = eachSystem (
        pkgs:
        {
          docs = pkgs.callPackage ./docs { };
        }
        // (pkgs.lib.packagesFromDirectoryRecursive {
          directory = ./pkgs;
          callPackage = pkgs.callPackage;
        })
        // (import ./gitkraken pkgs)
      );

      # Development environment with packages used by the module available in PATH
      devShells = eachSystem (pkgs: {
        default = pkgs.callPackage ./shell.nix { };
      });

      # Output tests as legacyPackages so that:
      # - they are runnable/buildable with 'nix run/build'
      # - they are not checked by 'nix flake check'
      # - they are not built by Garnix
      legacyPackages = eachSystem (pkgs: {
        tests = import ./tests pkgs;
      });
    };
}
