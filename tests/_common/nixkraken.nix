{ pkgs, ... }:

let
  # WARN: this MUST be updated to match NixOS version defined in tests/default.nix
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    # TODO: how to get hash
    sha256 = "sha256:0d41gr0c89a4y4lllzdgmbm54h9kn9fjnmavwpgw0w9xwqwnzpax";
  };

  # TODO: check why we cannot use 'pkgs.fetchFromGitHub' here due to an infinite recursion
  # home-manager = pkgs.fetchFromGitHub {
  #   owner = "nix-community";
  #   repo = "home-manager";
  #   # TODO: this should ultimately target release branches
  #   rev = "release-25.05";
  #   # TODO: until release branches are used, change this when module is updated
  #   # nix-prefetch-git --url git@github.com:nix-community/home-manager.git --rev refs/heads/release-25.05 --quiet | jq -r .hash
  #   hash = "sha256-Xd1vOeY9ccDf5VtVK12yM0FS6qqvfUop8UQlxEB+gTQ=";
  # };

  nixkraken = pkgs.fetchFromGitHub {
    owner = "nicolas-goudry";
    repo = "nixkraken";
    # TODO: this should ultimately target release branches
    rev = "main";
    # TODO: until release branches are used, change this when module is updated
    # nix-prefetch-git --url git@github.com:nicolas-goudry/nixkraken.git --quiet | jq -r .hash
    hash = "sha256-gTKFgTXBmWOCr7A70s3y4gr4LMzi7YpKIZxdpLWf1h4=";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.root = {
    imports = [
      (import "${nixkraken}/module.nix")
    ];

    home.stateVersion = "25.05";
  };
}
