{ self, inputs, ... }: {

  flake.nixosModules.alacritty = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myAlacritty
    ];
    fonts.packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.myAlacritty = inputs.wrapper-modules.wrappers.alacritty.wrap {
      inherit pkgs;
      settings = {
        font = {
          normal.family = "JetBrainsMono Nerd Font";
          size = 12;
        };
      };
    };
  };
}
