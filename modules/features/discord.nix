{...}: {
  flake.nixosModules.discord = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.discord.override {
        commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      })
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
