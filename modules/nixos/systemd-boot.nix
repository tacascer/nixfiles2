{ config, lib, pkgs, ... }:
let
  cfg = config.custom.systemd-boot;
in
{
  options.custom.systemd-boot = {
    timeout = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Boot menu timeout in seconds. Null uses the systemd-boot default.";
    };

    windows = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.efiDeviceHandle = lib.mkOption {
            type = lib.types.str;
            description = "EFI device handle for the Windows boot entry (discovered via UEFI Shell).";
          };
        }
      );
      default = { };
      description = "Windows boot entries to add to systemd-boot.";
    };

    kernelPackages = lib.mkOption {
      type = lib.types.raw;
      default = pkgs.linuxPackages;
      description = "Kernel packages to use.";
    };
  };

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.timeout = lib.mkIf (cfg.timeout != null) cfg.timeout;

    boot.loader.systemd-boot.windows = lib.mkIf (cfg.windows != { }) (
      lib.mapAttrs (_: w: { efiDeviceHandle = w.efiDeviceHandle; }) cfg.windows
    );

    boot.kernelPackages = cfg.kernelPackages;
  };
}
