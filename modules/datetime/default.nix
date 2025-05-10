{ config, lib, ... }@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;

  settings = {
    appDateFormat = cfg.datetime.dateFormat;
    appDateTimeFormat = cfg.datetime.format;
    appDateVerboseFormat = cfg.datetime.dateVerboseFormat;
    appDateWordFormat = cfg.datetime.dateWordFormat;
    appLocale = cfg.datetime.locale;
  };
in
{
  options.programs.nixkraken.datetime = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      Date/time settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.activation.nixkraken-datetime-config = lib.hm.dag.entryAfter [ "nixkraken-top-level" ] ''
      gk-configure -c "${lib.strings.escapeNixString (builtins.toJSON settings)}"
    '';
  };
}
