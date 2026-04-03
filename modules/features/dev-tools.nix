{ ... }:
{
  flake.nixosModules.dev-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jq pkgs.gh ];
    };
}
