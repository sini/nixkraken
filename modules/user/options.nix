{ lib, config, ... }:

{
  email = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userEmail;
    defaultText = "config.programs.git.userEmail";
    example = "email@example.com";
    description = ''
      Email to use as commit author email.

      Defaults to the value from `programs.git.userEmail`.
    '';
  };

  name = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userName;
    defaultText = "config.programs.git.userName";
    example = "John Doe";
    description = ''
      Name to use as commit author name.

      Defaults to the value from `programs.git.userName`.
    '';
  };
}
