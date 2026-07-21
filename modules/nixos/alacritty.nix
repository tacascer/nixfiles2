{ inputs, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  themeInputs = {
    gruvbox-dark = "${inputs.alacritty-theme}/themes/gruvbox_dark.toml";
    tokyo-night-storm = "${inputs.alacritty-theme}/themes/tokyo_night_storm.toml";
  };
in
{
  options.custom.alacritty.theme = lib.mkOption {
    type = lib.types.enum (builtins.attrNames themeInputs);
    default = "gruvbox-dark";
    description = "Alacritty color theme imported from alacritty-theme";
  };

  config.environment.systemPackages = [
    (inputs.wrapper-modules.wrappers.alacritty.wrap {
      inherit pkgs;
      settings = {
        general.import = [ themeInputs.${config.custom.alacritty.theme} ];
        window.decorations = "None";
        window.padding = {
          x = 8;
          y = 8;
        };
        font = {
          normal.family = config.custom.font.family;
          size = 12;
        };
        hints.enabled = [
          {
            command = "xdg-open";
            hyperlinks = true;
            post_processing = true;
            persist = false;
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\s{-}\\^⟨⟩`]+";
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
            mouse = {
              enabled = true;
              mods = "Shift";
            };
          }
        ];
      };
    })
  ];
}
