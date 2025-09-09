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
    assertions = [
      {
        assertion = cfg.tools.terminal.default == "custom" -> cfg.tools.terminal.package != null;
        message = "Terminal package (`tools.terminal.package`) must be set if default terminal is custom (`tools.terminal.default = \"custom\"`)";
      }
      {
        assertion = cfg.tools.terminal.package != null -> cfg.tools.terminal.default != "custom";
        message = "Terminal package (`tools.terminal.package`) cannot be set if default terminal is not custom (`tools.terminal.default != \"custom\"`)";
      }
      {
        assertion = cfg.tools.terminal.bin != null -> cfg.tools.terminal.package != null;
        message = "Terminal binary (`tools.terminal.bin`) cannot be set if terminal package (`tools.terminal.package`) is not set";
      }
    ];

    home.packages = lib.mkIf (cfg.tools.terminal.package != null) [ cfg.tools.terminal.package ];
  };
}
