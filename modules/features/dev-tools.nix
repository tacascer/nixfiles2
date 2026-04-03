{ inputs, ... }:
{
  flake.nixosModules.dev-tools =
    { pkgs, ... }:
    {
      programs.nix-ld.enable = true;

      environment.systemPackages = [
        pkgs.jq
        pkgs.gh
      ];
    };
}
