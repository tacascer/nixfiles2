{
  flake,
  config,
  pkgs,
  ...
}:
let
  omxPackage = flake.packages.${pkgs.stdenv.hostPlatform.system}.omx;
in
{
  config = {
    home-manager.extraSpecialArgs = {
      inherit omxPackage;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.codex
    ];
  };
}
