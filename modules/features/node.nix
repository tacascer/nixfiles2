{ self, ... }:
{
  flake.nixosModules.node =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        nodejs
        bun
      ];
    };
}
