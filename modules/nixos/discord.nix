{ pkgs, ... }:
let
  vesktop = pkgs.vesktop;
in
{
  environment.systemPackages = [ vesktop ];
}
