{ lib, system, ... }:

let
  versions = import ./versions.nix;

  fromNixpkgs =
    commit: hash:
    (import
      (fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${commit}.tar.gz";
        sha256 = hash;
      })
      {
        inherit system;

        config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "gitkraken"
          ];
      }
    ).gitkraken;
in
lib.mapAttrs' (
  version:
  { commit, hash }:
  lib.nameValuePair (lib.replaceStrings [ "." ] [ "-" ] version) (fromNixpkgs commit hash)
) versions
