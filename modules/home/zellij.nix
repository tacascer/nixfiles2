{ ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    attachExistingSession = true;

    settings = {
      mouse_mode = true;
      pane_frames = true;
      scroll_buffer_size = 10000;
      copy_on_select = true;
      simplified_ui = false;
      scrollback_editor = "vim";
    };
  };
}
