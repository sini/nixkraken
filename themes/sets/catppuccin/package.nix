{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  withVariants ? null,
}:

let
  defaultVariants = {
    frappe = "catppuccin-frappe.jsonc";
    latte = "catppuccin-latte.jsonc";
    macchiato = "catppuccin-macchiato.jsonc";
    mocha = "catppuccin-mocha.jsonc";
  };
  variantNames = lib.attrNames defaultVariants;
  variants = if withVariants == null then variantNames else withVariants;
in

assert lib.assertMsg (lib.isList variants) "withVariants must be a list";
assert lib.assertMsg (lib.length variants > 0) "withVariants cannot be empty";
assert lib.assertMsg (lib.all (variant: lib.elem variant variantNames)
  variants
) "withVariants uses invalid variants (valid variants: ${lib.concatStringsSep ", " variantNames})";

stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-catppuccin";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "gitkraken";
    rev = version;
    hash = "sha256-df4m2WUotT2yFPyJKEq46Eix/2C/N05q8aFrVQeH1sA=";
  };

  installPhase = lib.concatLines (
    lib.flatten [
      ''
        runHook preInstall
        mkdir -p $out
      ''
      (lib.map (variant: "cp themes/${defaultVariants.${variant}} $out") variants)
      "runHook postInstall"
    ]
  );

  passthru = lib.listToAttrs (
    lib.map (variant: lib.nameValuePair variant defaultVariants.${variant}) variants
  );

  meta = with lib; {
    description = "Soothing pastel theme for GitKraken";
    homepage = "https://github.com/catppuccin/gitkraken";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
