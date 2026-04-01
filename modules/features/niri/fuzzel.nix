{ self, inputs, ... }: {

  flake.nixosModules.fuzzel = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myFuzzel
    ];
    fonts.packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.myFuzzel = inputs.wrapper-modules.wrappers.fuzzel.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          prompt = ''"Hotkeys: "'';
        };
        border = {
          width = 2;
          radius = 12;
        };
        colors = {
          background = "1a1b26d0";
          text = "c0caf5ff";
          prompt = "7aa2f7ff";
          input = "c0caf5ff";
          match = "ff9e64ff";
          selection = "7aa2f740";
          selection-text = "c0caf5ff";
          selection-match = "ff9e64ff";
          placeholder = "565f89ff";
          counter = "565f89ff";
          border = "3b4261ff";
        };
      };
    };
  };
}
