{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.tools.terminal.package ];
  };
}
