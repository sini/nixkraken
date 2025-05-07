{ lib, ... }:

{
  meta.maintainers = with lib.maintainers; [ nicolas-goudry ];

  imports = [
    ./modules/top-level.nix
  ];
}
