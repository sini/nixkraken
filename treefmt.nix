#{ pkgs, ... }:
_:

{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;

  programs.shellcheck = {
    enable = true;

    excludes = [ ".envrc" ];
  };

  programs.prettier = {
    enable = true;

    includes = [
      "*.md"
      "*.js"
      "*.yaml"
    ];

    excludes = [
      "docs/theme/*"
    ];
  };
}
