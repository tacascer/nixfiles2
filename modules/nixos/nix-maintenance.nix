{ config, lib, ... }:
let
  cfg = config.custom.nix-maintenance;
in
{
  options.custom.nix-maintenance = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "~/myNixOS";
      description = "Path to the flake directory for auto-upgrade.";
    };
  };

  config = {
    nix.settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    # Reserve memory for desktop applications during builds.
    systemd.services.nix-daemon.serviceConfig = {
      MemoryHigh = "40%";
      MemoryMax = "50%";
    };

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
}
