{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  withVariants ? null,
}:

let
  defaultVariants = {
    default = "dracula-theme.jsonc";
    soft = "dracula-theme-soft.jsonc";
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
  name = "gitkraken-theme-dracula";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "dracula";
    repo = "gitkraken";
    rev = "v${version}";
    hash = "sha256-rgtOKdyaoPSv7aMLYq/QWB/YR6/65JhtJZlQ+qinZBA=";
  };

  installPhase = lib.concatLines (
    lib.flatten [
      ''
        runHook preInstall
        mkdir -p $out
      ''
      (lib.map (variant: "cp ${defaultVariants.${variant}} $out") variants)
      "runHook postInstall"
    ]
  );

  passthru = lib.listToAttrs (
    lib.map (variant: lib.nameValuePair variant defaultVariants.${variant}) variants
  );

  meta = with lib; {
    description = "Dracula dark theme for GitKraken";
    homepage = "https://github.com/dracula/gitkraken";
    license = licenses.mit;
    maintainers = [ maintainers.nicolas-goudry ];
  };
}
