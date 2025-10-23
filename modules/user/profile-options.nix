{ config, lib, ... }:

{
  email = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userEmail;
    defaultText = "config.programs.git.userEmail";
    example = "email@example.com";
    description = ''
      Email to use as commit author email.

      ::: warning

      This option is required when [`skipTutorial`](/reference/root.md#skiptutorial) is enabled.

      :::
      <!-- scope: profile -->
    '';
  };

  name = lib.mkOption {
    type = with lib.types; nullOr str;
    default = config.programs.git.userName;
    defaultText = "config.programs.git.userName";
    example = "John Doe";
    description = ''
      Name to use as commit author name.

      ::: warning

      This option is required when [`skipTutorial`](/reference/root.md#skiptutorial) is enabled.

      :::
      <!-- scope: profile -->
    '';
  };
}
