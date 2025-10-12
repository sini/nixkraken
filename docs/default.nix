{
  pkgs ? import <nixpkgs> { },
  gitRev ? "dirty",
}:

let
  inherit (pkgs)
    lib
    callPackage
    stdenvNoCC
    nixosOptionsDoc
    colorized-logs
    mdbook
    mdbook-alerts
    mdbook-linkcheck
    mdbook-mermaid
    nodejs
    rustc
    ;

  # Modules reference
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

  # List of cached GitKraken commits as Markdown quoted list
  # Replacement of @CACHED_COMMIT_LIST@
  gitkrakenVersions = import ../gitkraken/versions.nix;
  cachedCommitsList = lib.mapAttrsToList (
    version:
    { commit, ... }:
    "> - GitKraken v${version}: [\\`${commit}\\`](https://github.com/nixos/nixpkgs/blob/${commit})"
  ) gitkrakenVersions;

  # List of details about individual themes as Markdown table rows
  # Replacement of @THEMES_LIST@
  themes = callPackage ../themes { };
  themesList = lib.collect lib.isString (
    lib.mapAttrs (
      set: variants:
      lib.mapAttrs' (
        variant: drv:
        let
          src = drv.src.gitRepoUrl or drv.src.url;
        in
        lib.nameValuePair "${set}-${variant}" "| ${lib.toSentenceCase set} | ${
          if drv.prettyName == null then lib.toSentenceCase variant else drv.prettyName
        } | [Source](${src}) | `${set}.${variant}` |"
      ) (lib.filterAttrs (name: _: name != "override" && name != "overrideDerivation") variants)
    ) themes.passthru
  );

  # Local packages
  # Used to replace command usages
  localPkgs = callPackage ../pkgs { };
  localPkgsNames = lib.attrNames (lib.filterAttrs (name: value: lib.isDerivation value) localPkgs);
  commandUsagesBuilder = lib.concatLines (
    lib.map (
      pkg:
      let
        file = if pkg == "decrypt" || pkg == "encrypt" then "encrypt-decrypt" else pkg;
        substVar = "GK_${lib.toUpper pkg}_USAGE";
      in
      ''
        substituteInPlace src/dev/packages/${file}.md --subst-var-by ${substVar} "$(${lib.getExe localPkgs.${pkg}} --help | ansi2txt)"
      ''
    ) localPkgsNames
  );
in
stdenvNoCC.mkDerivation {
  name = "nixkraken-docs";
  src = ./.;

  nativeBuildInputs = [
    colorized-logs
    nodejs
    mdbook
    mdbook-alerts
    mdbook-linkcheck
    mdbook-mermaid
  ];

  dontConfigure = true;
  doCheck = true;
  dontFixup = true;

  # Patch book configuration to disable web links checking since network is not available
  patches = [ ./book.toml.nix-build.patch ];

  preBuild = ''
    # Build module reference
    GIT_REV="${gitRev}" node build-doc.js ${optionsDoc.optionsJSON}/share/doc/nixos/options.json

    # Handle OPTIONS_ROOT replacements in all option reference files
    for f in $(find src/options -type f -name '*.md'); do
      fdir=$(dirname $f)
      rel_root=$(realpath --relative-to=$fdir src/options)
      substituteInPlace $f --subst-var-by OPTIONS_ROOT $rel_root
    done

    # Handle other replacements
    substituteInPlace src/guides/caching.md --replace-fail "> @CACHED_COMMIT_LIST@" "${lib.concatLines cachedCommitsList}"
    substituteInPlace src/guides/theming.md --subst-var-by THEMES_LIST '${lib.concatLines themesList}'
    ${commandUsagesBuilder}
  '';

  buildPhase = ''
    runHook preBuild

    mdbook build

    runHook postBuild
  '';

  nativeCheckInputs = [
    mdbook
    mdbook-alerts
    mdbook-linkcheck
    mdbook-mermaid
    rustc
  ];

  checkPhase = ''
    runHook preCheck

    mdbook test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mv book/html $out

    runHook postInstall
  '';
}
