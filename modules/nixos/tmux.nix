{ inputs, ... }:
{ pkgs, ... }:
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
        {
          plugin = pkgs.tmuxPlugins.tmux-fzf;
          configBefore = ''
            set-environment -g TMUX_FZF_ORDER 'pane|window|session|copy-mode|command|keybinding|clipboard|process'
            set-environment -g TMUX_FZF_PANE_FORMAT '[#{window_name}] #{pane_current_path} :: #{pane_current_command} [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}] #{?pane_active,[active],[inactive]}'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          configBefore = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          configBefore = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
        pkgs.tmuxPlugins.yank
        {
          plugin = inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default;
          configBefore = ''
            set -g window-status-format '#I #{nerd_font_window_name} '
            set -g window-status-current-format '#I #{nerd_font_window_name} '
          '';
        }
        pkgs.tmuxPlugins.tmux-powerline
      ];
      configAfter = ''
        set -g renumber-windows on

        unbind x
        bind x confirm-before -p 'Kill pane #P? (y/n)' kill-pane

        unbind '&'
        bind '&' confirm-before -p 'Kill window #I? (y/n)' kill-window

        bind '"' split-window -v -c '#{pane_current_path}'
        bind % split-window -h -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'
      '';
    })
  ];
}
