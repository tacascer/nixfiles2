{ ... }:
{
  programs.firefox = {
    enable = true;

    profiles.default = { };

    policies.Preferences."widget.use-xdg-desktop-portal.file-picker" = {
      Value = 1;
      Status = "locked";
    };
  };

  stylix.targets.firefox.profileNames = [ "default" ];
}
