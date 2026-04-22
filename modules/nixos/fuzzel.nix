{ inputs, ... }:
{ pkgs, config, ... }:
let
  palette = config.custom.colorScheme.palette;
in
{
  environment.systemPackages = [
    (inputs.wrapper-modules.wrappers.fuzzel.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=13";
          prompt = ''"  "'';
          width = 80;
          horizontal-pad = 24;
          vertical-pad = 12;
          inner-pad = 8;
          line-height = 22;
          lines = 8;
          letter-spacing = 0.5;
        };
        border = {
          width = 2;
          radius = 16;
        };
        colors = {
          background = "${palette.base00}f0";
          text = "${palette.base05}ff";
          prompt = "${palette.base0D}ff";
          input = "${palette.base06}ff";
          match = "${palette.base09}ff";
          selection = "${palette.base01}ff";
          selection-text = "${palette.base0D}ff";
          selection-match = "${palette.base09}ff";
          placeholder = "${palette.base03}ff";
          counter = "${palette.base04}ff";
          border = "${palette.base01}ff";
        };
      };
    })
  ];
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
