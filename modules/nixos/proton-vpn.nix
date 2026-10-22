{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.proton-vpn ];

  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };

  # Blocked DNS requests can exhaust nsncd workers during kill-switch activation.
  # Increase the pool so NSS requests from resolvconf can complete.
  # https://github.com/twosigma/nsncd#configuration
  systemd.services.nscd.environment.NSNCD_WORKER_COUNT = "32";

  services.gnome.gnome-keyring.enable = true;
}
