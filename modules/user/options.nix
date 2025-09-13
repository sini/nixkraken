{ config, lib, ... }:

{
  email = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userEmail;
    defaultText = "config.programs.git.userEmail";
    example = "email@example.com";
    description = ''
      Email to use as commit author email.

      > [!IMPORTANT]
      >
      > This option is required when [`skipTutorial`](@OPTIONS_ROOT@/nixkraken.md#skiptutorial) is enabled.
    '';
  };

  name = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userName;
    defaultText = "config.programs.git.userName";
    example = "John Doe";
    description = ''
      Name to use as commit author name.

      > [!IMPORTANT]
      >
      > This option is required when [`skipTutorial`](@OPTIONS_ROOT@/nixkraken.md#skiptutorial) is enabled.
    '';
  };
}
