{
  inputs,
  ...
}:
{
  flake.nixosModules.alacritty =
    { pkgs, config, ... }:
    let
      palette = config.custom.colorScheme.palette;
    in
    {
      environment.systemPackages = [
        (inputs.wrapper-modules.wrappers.alacritty.wrap {
          inherit pkgs;
          settings = {
            window.decorations = "None";
            window.padding = {
              x = 8;
              y = 8;
            };
            font = {
              normal.family = "JetBrainsMono Nerd Font";
              size = 12;
            };
            colors = {
              primary = {
                background = "#${palette.base00}";
                foreground = "#${palette.base05}";
              };
              normal = {
                black = "#${palette.base00}";
                red = "#${palette.base08}";
                green = "#${palette.base0B}";
                yellow = "#${palette.base0A}";
                blue = "#${palette.base0D}";
                magenta = "#${palette.base0E}";
                cyan = "#${palette.base0C}";
                white = "#${palette.base05}";
              };
              bright = {
                black = "#${palette.base03}";
                red = "#${palette.base08}";
                green = "#${palette.base0B}";
                yellow = "#${palette.base0A}";
                blue = "#${palette.base0D}";
                magenta = "#${palette.base0E}";
                cyan = "#${palette.base0C}";
                white = "#${palette.base07}";
              };
            };
          };
        })
      ];
      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
