{
  pkgs,
  tmuxNerdFontWindowName,
  ...
}:
{
  home.packages = [ pkgs.fzf ];

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    clock24 = true;
    historyLimit = 5000;
    terminal = "tmux-256color";
    secureSocket = true;

    plugins = [
      pkgs.tmuxPlugins.fzf-tmux-url
      {
        plugin = pkgs.tmuxPlugins.tmux-fzf;
        extraConfig = ''
          set-environment -g TMUX_FZF_ORDER 'pane|window|session|copy-mode|command|keybinding|clipboard|process'
          set-environment -g TMUX_FZF_PANE_FORMAT '[#{window_name}] #{pane_current_path} :: #{pane_current_command} [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}] #{?pane_active,[active],[inactive]}'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      pkgs.tmuxPlugins.yank
      {
        plugin = tmuxNerdFontWindowName;
        extraConfig = ''
          set -g window-status-format '#I #{nerd_font_window_name} '
          set -g window-status-current-format '#I #{nerd_font_window_name} '
        '';
      }
      pkgs.tmuxPlugins.tmux-powerline
    ];

    extraConfig = ''
      set -g display-panes-colour default
      set-option -ga update-environment "TERM TERM_PROGRAM"
      set -gq allow-passthrough on
      set -g visual-activity off

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

      set -g renumber-windows on
      set -g extended-keys on
      set -g extended-keys-format csi-u

      unbind x
      bind x confirm-before -p 'Kill pane #P? (y/n)' kill-pane

      unbind '&'
      bind '&' confirm-before -p 'Kill window #I? (y/n)' kill-window

      bind '"' split-window -v -c '#{pane_current_path}'
      bind % split-window -h -c '#{pane_current_path}'
      bind c new-window -c '#{pane_current_path}'
    '';
  };
}
