{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.proton-vpn ];

  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };

  services.gnome.gnome-keyring.enable = true;
}
