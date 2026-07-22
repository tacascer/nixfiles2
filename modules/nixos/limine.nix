{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.limine;
in
{
  options.custom.limine = {
    extraEntries = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Limine bootloader entries (e.g. Windows chainloading).";
    };
  };

  config.boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;

        extraEntries = cfg.extraEntries;

        style.graphicalTerminal.font.scale = "2x2";
      };
    };
  };
}
