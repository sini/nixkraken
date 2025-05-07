{ lib, ... }:

{
  options = {
    ssh = lib.mkOption {
      type = lib.types.submodule {
        options = {
          useLocalAgent = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Use local SSH agent instead of defining SSH key to use.
            '';
          };

          privateKey = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = ''
              Path to the SSH private key file to use.
            '';
          };

          publicKey = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = ''
              Path to the SSH public key file to use.
            '';
          };
        };
      };
      default = { };
      description = ''
        SSH settings.
      '';
    };
  };
}
