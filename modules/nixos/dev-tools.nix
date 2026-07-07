{ pkgs, ... }:
{
  programs.bash = {
    shellAliases = {
      bazel = "bazelisk";
    };
  };
  programs.nix-ld.enable = true;
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    python314
    bazelisk
    biome
    cargo
    lcov
    jq
    gh
    lazydocker
    lazygit
    nixd
    fd
    rust-analyzer
    rustc
    util-linux
    yaml-language-server
  ];
}
