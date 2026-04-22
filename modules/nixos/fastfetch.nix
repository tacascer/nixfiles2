{ flake, ... }:
{ pkgs, ... }:
{
  environment.systemPackages = [
    flake.packages.${pkgs.stdenv.hostPlatform.system}.fastfetch
  ];
}
