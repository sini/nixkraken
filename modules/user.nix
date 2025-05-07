{ lib, ... }:

{
  options.programs.nixkraken = {
    user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "email@example.com";
            description = ''
              Email to use as commit author email.
            '';
          };

          name = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "John Doe";
            description = ''
              Name to use as commit author name.
            '';
          };
        };
      };
      default = { };
      description = ''
        User settings.
      '';
    };
  };
}
