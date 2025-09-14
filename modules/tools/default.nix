{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  appOpts = import ./app-options.nix args;
  profileOpts = import ./profile-options.nix args;
in
{
  options.programs.nixkraken.tools = lib.mkOption {
    type = lib.types.submodule {
      options = lib.recursiveUpdate appOpts profileOpts;
    };
    default = { };
    description = ''
      External tools settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.flatten (
      (lib.optional (cfg.tools.editor.package != null) cfg.tools.editor.package)
      ++ (lib.optional (cfg.tools.terminal.package != null) cfg.tools.terminal.package)
    );
  };
}
