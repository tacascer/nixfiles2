{ config, lib, pkgs, ... }:
let
  cfg = config.custom.limine;
  palette = config.custom.colorScheme.palette;
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

        style = {
          wallpapers = [ "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg" ];
          backdrop = palette.base00;
          graphicalTerminal = {
            foreground = palette.base05;
            background = "FF${palette.base00}";
            font.scale = "2x2";
            palette = "${palette.base00};${palette.base08};${palette.base0B};${palette.base0A};${palette.base0D};${palette.base0E};${palette.base0C};${palette.base04}";
            brightPalette = "${palette.base03};${palette.base08};${palette.base0B};${palette.base0A};${palette.base0D};${palette.base0E};${palette.base0C};${palette.base05}";
          };
        };
      };
    };
  };
}
