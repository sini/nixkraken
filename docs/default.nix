{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs)
    lib
    callPackage
    buildNpmPackage
    colorized-logs
    git
    ;

  # List of cached GitKraken commits as Markdown quoted list
  # Replacement of @CACHED_COMMIT_LIST@
  gitkrakenVersions = import ../gitkraken/versions.nix;
  cachedCommitsList = lib.mapAttrsToList (
    version:
    { commit, ... }:
    "- GitKraken v${version}: [\\`${commit}\\`](https://github.com/nixos/nixpkgs/blob/${commit})"
  ) gitkrakenVersions;

  # List of details about individual themes as Markdown table rows
  # Replacement of @THEMES_LIST@
  themes = callPackage ../themes { };
  themesList = lib.collect lib.isString (
    lib.mapAttrs (
      theme: drv:
      let
        src = drv.src.gitRepoUrl or drv.src.url;
        # To Title Case
        prettyName = lib.concatStringsSep " " (
          lib.map (word: lib.toSentenceCase word) (lib.splitString "-" theme)
        );
      in
      lib.mapAttrs' (
        variant: _:
        lib.nameValuePair "${theme}-${variant}" "| ${
          if theme == "nineteen-eighty-four" then "1984" else prettyName
        } | ${
          if variant == "default" then "_N/A_" else lib.toSentenceCase variant
        } | `${theme}` | `${variant}` | [Source](${src}) |"
      ) drv.passthru
    ) (lib.filterAttrs (theme: _: theme != "all") themes.passthru)
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
        substituteInPlace src/contrib/pkgs/${file}.md --subst-var-by ${substVar} "$(${lib.getExe localPkgs.${pkg}} --help | ansi2txt)"
      ''
    ) localPkgsNames
  );
in
buildNpmPackage rec {
  name = "nixkraken-docs";
  src = lib.fileset.toSource {
    root = ./..;

    # Include here, in addition to docs directory (./.), any directory needed when building
    # This is useful if documentation is including files from the project
    fileset = lib.fileset.unions [
      ./.
      ./../themes
    ];
  };
  sourceRoot = "${src.name}/docs";

  npmDepsHash = "sha256-OG1nlSWilUolmP+02Q/Jp/lg5BYHOpB7CpGuBJyzUk8=";
  npmPackFlags = [ "--ignore-scripts" ]; # Prevents npm pack to build the project

  nativeBuildInputs = [
    # ANSI escaped color codes to plain ASCII text, used by commandUsagesBuilder
    colorized-logs
    # Required by VitePress
    git
  ];

  preBuild = ''
    # Handle replacements
    substituteInPlace src/guide/user/caching.md --subst-var-by CACHED_COMMIT_LIST '${lib.concatLines cachedCommitsList}'
    substituteInPlace src/guide/user/theming.md --subst-var-by THEMES_LIST '${lib.concatLines themesList}'
    ${commandUsagesBuilder}
  '';

  installPhase = ''
    runHook preInstall

    mv .vitepress/dist $out

    runHook postInstall
  '';
}
