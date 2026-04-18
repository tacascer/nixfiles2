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
        pkgs.fzf
        (inputs.wrapper-modules.wrappers.tmux.wrap {
          inherit pkgs;
          prefix = "C-a";
          modeKeys = "vi";
          statusKeys = "vi";
          vimVisualKeys = true;
          mouse = true;
          historyLimit = 5000;
          terminal = "tmux-256color";
          plugins = [
            pkgs.tmuxPlugins.fzf-tmux-url
            pkgs.tmuxPlugins.resurrect
            {
              plugin = pkgs.tmuxPlugins.continuum;
              configBefore = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '15'
              '';
            }
            pkgs.tmuxPlugins.yank
          ];
          configAfter = ''
            bind '"' split-window -v -c '#{pane_current_path}'
            bind % split-window -h -c '#{pane_current_path}'
            bind c new-window -c '#{pane_current_path}'
            set -g @resurrect-capture-pane-contents 'on'
            set -g status-style 'bg=#${palette.base01},fg=#${palette.base05}'
            set -g status-left '#[bg=#${palette.base0D},fg=#${palette.base00},bold] #S #[default] '
            set -g status-right '#[fg=#${palette.base04}] %H:%M %d-%b '
            set -g window-status-current-style 'bg=#${palette.base02},fg=#${palette.base0D},bold'
            set -g window-status-style 'fg=#${palette.base04}'
            set -g pane-border-style 'fg=#${palette.base02}'
            set -g pane-active-border-style 'fg=#${palette.base0D}'
            set -g message-style 'bg=#${palette.base01},fg=#${palette.base05}'
          '';
        })
      ];
    };
}
