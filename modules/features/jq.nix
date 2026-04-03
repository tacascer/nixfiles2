{ ... }:
{
  flake.nixosModules.jq =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jq ];
    };
}
