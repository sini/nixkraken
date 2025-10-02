{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs)
    stdenv
    lib
    rustPlatform
    fetchFromGitHub
    cmake
    libiconv
    openssl
    pkg-config
    ;
in
rustPlatform.buildRustPackage {
  pname = "convco";
  version = "0.6.2-custom";

  src = fetchFromGitHub {
    owner = "nicolas-goudry";
    repo = "convco";
    rev = "feat/better-scope-validation";
    hash = "sha256-Lvf+Hx2tIUpHaFtDl2/NtSmiH1mcvTdDqtZbDEGI+Rs=";
  };

  cargoHash = "sha256-C1jJeAHsbWy3buTNy9X/iic+qDnXCFaX47FJwzKmk/o=";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  checkFlags = [
    # disable tests requiring git repository
    "--skip=git::tests::test_find_last_unordered_prerelease"
    "--skip=git::tests::test_find_matching_prerelease"
    "--skip=git::tests::test_find_matching_prerelease_without_matching_release"
  ];

  meta = with lib; {
    description = "Conventional commit cli";
    mainProgram = "convco";
    homepage = "https://github.com/nicolas-goudyr/convco";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [
      nicolas-goudry
    ];
  };
}
