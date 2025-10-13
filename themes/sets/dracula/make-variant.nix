{
  pkgs ? import <nixpkgs> { },
  name ? null,
  prettyName ? null,
}@args:

pkgs.callPackage ../../make-theme.nix {
  inherit prettyName;

  src = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "gitkraken";
    rev = "v0.5.0";
    hash = "sha256-rgtOKdyaoPSv7aMLYq/QWB/YR6/65JhtJZlQ+qinZBA=";
  };

  name = args.name or "dracula";
  path = "dracula-theme${if name == null then "" else "-${args.name}"}.jsonc";

  meta = with pkgs.lib; {
    description = "Dracula dark theme for GitKraken";
    homepage = "https://github.com/dracula/gitkraken";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
