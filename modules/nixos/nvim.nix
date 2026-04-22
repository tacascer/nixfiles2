{ flake, ... }:
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.wl-clipboard
    flake.packages.${pkgs.stdenv.hostPlatform.system}.nvim
  ];
}
