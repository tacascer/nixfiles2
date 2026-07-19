{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.font;
in
{
  options.custom.font = {
    family = lib.mkOption {
      type = lib.types.str;
      default = "Hack Nerd Font";
      description = "Default font family used by the system and configured applications.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nerd-fonts.hack;
      description = "Package providing the default font family.";
    };
  };

  config = {
    fonts.packages = [ cfg.package ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = lib.mkForce [ cfg.family ];
      serif = lib.mkForce [ cfg.family ];
      monospace = lib.mkForce [ cfg.family ];
    };
  };
}
