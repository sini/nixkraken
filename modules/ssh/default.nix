{ lib, ... }@args:

let
  options = import ./options.nix args;
in
{
  options.programs.nixkraken.ssh = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      SSH settings.
    '';
  };
}
