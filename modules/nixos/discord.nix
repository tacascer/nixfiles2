{ pkgs, ... }:
let
  vesktop = pkgs.vesktop.override {
    # Upstream nixpkgs pins Vesktop to pnpm_10_29_2 for an
    # electron-builder compatibility break introduced in 10.29.3.
    # The package's electron-builder dependency is now new enough for the
    # current pnpm_10, and 10.29.2 is marked insecure.
    pnpm_10_29_2 = pkgs.pnpm_10;
  };
in
{
  environment.systemPackages = [ vesktop ];
}
