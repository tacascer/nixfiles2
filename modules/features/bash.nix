{self, ...}: {
  flake.nixosModules.bash = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.custom.bash;
    flakeRef = "${cfg.flakeDir}#${cfg.host}";
  in {
    options.custom.bash = {
      flakeDir = lib.mkOption {
        type = lib.types.str;
        description = "Path to the flake directory.";
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = "Host name for the flake reference.";
      };
    };

    config.programs.starship.enable = true;

    config.programs.bash = {
      completion.enable = true;
      shellAliases = {
        sysup = "sudo nixos-rebuild switch --flake ${flakeRef}";
        sysupup = "sudo nix flake update --flake ${cfg.flakeDir} && sudo nixos-rebuild switch --flake ${flakeRef}";
        claude-yolo = "claude --dangerously-skip-permissions";
      };
    };
  };
}
