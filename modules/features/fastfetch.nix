{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.fastfetch = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myFastFetch
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.myFastFetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
    };
  };
}
