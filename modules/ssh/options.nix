{ config, lib, ... }:

{
  useLocalAgent = lib.mkOption {
    type = lib.types.bool;
    default = config.programs.ssh.enable;
    defaultText = "config.programs.ssh.enable";
    description = ''
      Use local SSH agent instead of defining SSH key to use.

      Defaults to the value of `programs.ssh.enable`.
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
}
