{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.podman ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };
}
