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
    cargo
    jq
    gh
    nixd
    rustc
    util-linux
  ];
}
