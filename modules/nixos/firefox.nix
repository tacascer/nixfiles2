{
  programs.firefox = {
    enable = true;
    preferences = {
      "extensions.activeThemeID" = "default-theme@mozilla.org";
      "layout.css.prefers-color-scheme.content-override" = 2;
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
}
