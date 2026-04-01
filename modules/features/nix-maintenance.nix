{self, ...}: {
  flake.nixosModules.nix-maintenance = {
    config,
    lib,
    ...
  }: let
    cfg = config.custom.nix-maintenance;
  in {
    options.custom.nix-maintenance = {
      flakeDir = lib.mkOption {
        type = lib.types.str;
        default = "~/myNixOS";
        description = "Path to the flake directory for auto-upgrade.";
      };
    };

    config = {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      system.autoUpgrade = {
        enable = true;
        flake = cfg.flakeDir;
        flags = [
          "--update-input"
          "nixpkgs"
          "-L"
        ];
        allowReboot = true;
      };
    };
  };
}
