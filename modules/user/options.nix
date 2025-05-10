{ lib, ... }:

{
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
}
