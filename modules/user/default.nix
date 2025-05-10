{ lib, ... }@args:

let
  options = import ./options.nix args;
in
{
  options.programs.nixkraken.user = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      User settings.
    '';
  };
}
