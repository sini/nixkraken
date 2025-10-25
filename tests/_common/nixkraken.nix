_:

let
  # WARN: this MUST be updated to match nixpkgs version defined in flake.nix
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    # nix-prefetch-url --unpack https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz 2>/dev/null
    sha256 = "0q3lv288xlzxczh6lc5lcw0zj9qskvjw3pzsrgvdh8rl8ibyq75s";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # TODO: this currently doesn't seem to work for some reason, fix it
  nix.extraOptions = ''
    extra-substituters = https://cache.garnix.io
    extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
  '';

  home-manager.users.root = {
    imports = [
      (import ../../module.nix)
    ];

    home.stateVersion = "25.05";
  };
}
