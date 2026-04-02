{ ... }:
{
  flake.nixosModules.spotify =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.spotify ];
    };
}
