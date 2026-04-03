{
  inputs,
  ...
}:
{
  flake.nixosModules.tmux =
    { pkgs, config, ... }:
    let
      palette = config.custom.colorScheme.palette;
    in
    {
      environment.systemPackages = [
        (inputs.wrapper-modules.wrappers.tmux.wrap {
          inherit pkgs;
          settings = {
            prefix = "C-a";
            modeKeys = "vi";
            statusKeys = "vi";
            vimVisualKeys = true;
            mouse = true;
            historyLimit = 5000;
            terminal = "tmux-256color";
            plugins = [
              pkgs.tmuxPlugins.resurrect
              pkgs.tmuxPlugins.yank
            ];
            configAfter = ''
              set -g status-style 'bg=#${palette.base01},fg=#${palette.base05}'
              set -g status-left '#[bg=#${palette.base0D},fg=#${palette.base00},bold] #S #[default] '
              set -g status-right '#[fg=#${palette.base04}] %H:%M %d-%b '
              set -g window-status-current-style 'bg=#${palette.base02},fg=#${palette.base0D},bold'
              set -g window-status-style 'fg=#${palette.base04}'
              set -g pane-border-style 'fg=#${palette.base02}'
              set -g pane-active-border-style 'fg=#${palette.base0D}'
              set -g message-style 'bg=#${palette.base01},fg=#${palette.base05}'
            '';
          };
        })
      ];
    };
}
