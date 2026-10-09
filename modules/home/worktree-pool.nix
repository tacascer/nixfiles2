{ flake, ... }:
{ pkgs, ... }:
{
  home.packages = [ flake.packages.${pkgs.stdenv.hostPlatform.system}.worktree-pool ];
}
