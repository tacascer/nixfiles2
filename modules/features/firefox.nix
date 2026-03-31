{...}: {
  flake.nixosModules.firefox = {
    programs.firefox = {
      enable = true;
      preferences = {
        # Use the default theme that follows system light/dark preference
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        # Follow system color scheme for web content
        "layout.css.prefers-color-scheme.content-override" = 2;
        # Enable KDE/Plasma integration for file dialogs
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
