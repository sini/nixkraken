{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib nixosOptionsDoc;

  moduleEval = lib.evalModules {
    modules = [
      (_: {
        imports = [ ../module.nix ];
        config._module.check = false;
      })
    ];
  };

  optionsDoc = nixosOptionsDoc {
    inherit (moduleEval) options;
  };
in
pkgs.runCommand "extract-options-json" { } ''
  mkdir -p $out
  cp ${optionsDoc.optionsJSON}/share/doc/nixos/options.json $out
''
