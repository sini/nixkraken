#{ pkgs, ... }:
_:

{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.black.enable = true;

  programs.prettier = {
    enable = true;

    excludes = [ "docs/theme/highlight.js" ];
  };

  programs.shellcheck = {
    enable = true;

    excludes = [ ".envrc" ];
  };
}
