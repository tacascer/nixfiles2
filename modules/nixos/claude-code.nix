{ flake, ... }:
{ pkgs, ... }:
{
  environment.systemPackages = [
    flake.packages.${pkgs.stdenv.hostPlatform.system}."claude-code"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    shellAliases = {
      claude-yolo = "claude --dangerously-skip-permissions";
    };
  };
}
