{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./app-options.nix args;

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
    programs.nixkraken._submoduleSettings.datetime = settings;
  };
}
