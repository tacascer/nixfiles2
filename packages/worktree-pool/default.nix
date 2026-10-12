{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "worktree-pool";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "LowkeyLab";
    repo = "worktree-pool";
    rev = "eea69ea10a1ce577f8a997181289edb21a34a75d";
    hash = "sha256-VkYyZRLu49LAtGCVMUVobR5ZI/sKED1QSq3hPx5d2dY=";
  };
  cargoHash = "sha256-bfNQ472mfBuJQm3EhB7QEHnXh72fvEnEztYQyMKSeWs=";

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
    homepage = "https://github.com/LowkeyLab/worktree-pool";
    license = pkgs.lib.licenses.agpl3Only;
    mainProgram = "worktree-pool";
    # Match the upstream runtime support contract.
    platforms = [ "x86_64-linux" ];
  };
}
