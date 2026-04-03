{ inputs, ... }:
{
  flake.nixosModules.dev-tools =
    { pkgs, ... }:
    {
      programs.nix-ld.enable = true;
      programs.direnv.enable = true;

      environment.systemPackages = [
        pkgs.jq
        pkgs.gh
      ];
    };
}
