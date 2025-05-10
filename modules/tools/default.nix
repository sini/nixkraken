{ lib, ... }@args:

let
  options = import ./options.nix args;
in
{
  options.programs.nixkraken.tools = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      External tools settings.
    '';
  };
}
