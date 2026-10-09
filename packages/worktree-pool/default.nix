{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "worktree-pool";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "LowkeyLab";
    repo = "bazel-repo";
    rev = "44063c8865be48acab7d844330d0a9687787e187";
    hash = "sha256-AemqE7a0sadm0J/d0bD9DqfLwCxPYqizuTKM2bUlGAg=";
  };
  sourceRoot = "source/worktree_pool";
  cargoHash = "sha256-5XHXV3W6g/dvuseJ9Wvx81VE86moBeRhZt31e7hddOg=";

  nativeBuildInputs = [ pkgs.makeWrapper ];
  nativeCheckInputs = [ pkgs.git ];

  postInstall = ''
    wrapProgram "$out/bin/worktree-pool" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git ]}
    install -Dm644 LICENSE "$out/share/licenses/worktree-pool/LICENSE"
    install -Dm644 README.md "$out/share/doc/worktree-pool/README.md"
    install -Dm644 WIRE_SCHEMA.md "$out/share/doc/worktree-pool/WIRE_SCHEMA.md"
    install -Dm644 DEPENDENCIES.md "$out/share/doc/worktree-pool/DEPENDENCIES.md"
  '';

  meta = {
    description = "Explicit ownership for persistent local Git worktrees";
    homepage = "https://github.com/LowkeyLab/bazel-repo/tree/44063c8865be48acab7d844330d0a9687787e187/worktree_pool";
    license = pkgs.lib.licenses.agpl3Only;
    mainProgram = "worktree-pool";
    # Match the upstream runtime support contract.
    platforms = [ "x86_64-linux" ];
  };
}
