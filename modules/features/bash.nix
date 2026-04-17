{ self, ... }:
{
  flake.nixosModules.bash =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.custom.bash;
    in
    {
      options.custom.bash = {
        flakeDir = lib.mkOption {
          type = lib.types.str;
          description = "Path to the flake directory.";
        };
      };

      config.programs.starship.enable = true;

      config.programs.bash = {
        completion.enable = true;
        shellAliases = {
          nrbs = "sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
          nrbsu = "sudo nix flake update --flake ${cfg.flakeDir} && sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
        };
      };
    };
}
