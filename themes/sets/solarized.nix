{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  withVariants ? null,
}:

let
  defaultVariants = {
    dark = "solarized-dark.jsonc";
    light = "solarized-light.jsonc";
  };
  variantNames = lib.attrNames defaultVariants;
  variants = lib.defaultTo variantNames withVariants;
in

assert lib.assertMsg (lib.isList variants) "withVariants must be a list";
assert lib.assertMsg (lib.length variants > 0) "withVariants cannot be empty";
assert lib.assertMsg (lib.all (variant: lib.elem variant variantNames)
  variants
) "withVariants uses invalid variants (valid variants: ${lib.concatStringsSep ", " variantNames})";

stdenvNoCC.mkDerivation rec {
  name = "gitkraken-theme-solarized";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jonbunator";
    repo = "gitkraken-custom-themes";
    rev = "v${version}";
    hash = "sha256-RCwitJ6HeFYJNsrc2lsVqAe1urfsi1RcxBYXXni6Fv0=";
  };

  installPhase = lib.concatLines (
    lib.flatten [
      ''
        runHook preInstall
        mkdir -p $out
      ''
      (lib.map (variant: "cp 'Themes/Solarized/${defaultVariants.${variant}}' $out") variants)
      "runHook postInstall"
    ]
  );

  passthru = lib.listToAttrs (
    lib.map (variant: lib.nameValuePair variant defaultVariants.${variant}) variants
  );

  meta = {
    description = "Solarized theme for GitKraken";
    homepage = "https://github.com/jonbunator/gitkraken-custom-themes/tree/v${version}/Themes/Solarized";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nicolas-goudry ];
  };
}
