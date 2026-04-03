{
  inputs,
  ...
}:
{
  flake.nixosModules.fuzzel =
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
              font = "JetBrainsMono Nerd Font:size=12";
              prompt = ''"Hotkeys: "'';
            };
            border = {
              width = 2;
              radius = 12;
            };
            colors = {
              background = "${palette.base00}d0";
              text = "${palette.base05}ff";
              prompt = "${palette.base0D}ff";
              input = "${palette.base05}ff";
              match = "${palette.base09}ff";
              selection = "${palette.base0D}40";
              selection-text = "${palette.base05}ff";
              selection-match = "${palette.base09}ff";
              placeholder = "${palette.base03}ff";
              counter = "${palette.base03}ff";
              border = "${palette.base02}ff";
            };
          };
        })
      ];
      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
