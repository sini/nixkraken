{
  config,
  lib,
  ...
}@args:

let
  cfg = config.programs.nixkraken;
  options = import ./options.nix args;
in
{
  options.programs.nixkraken.ssh = lib.mkOption {
    type = lib.types.submodule {
      inherit options;
    };
    default = { };
    description = ''
      SSH settings.
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ssh.useLocalAgent -> (cfg.ssh.privateKey == null && cfg.ssh.publicKey == null);
        message = "SSH keys cannot be set when `useLocalAgent` is true";
      }
    ];
  };
}
