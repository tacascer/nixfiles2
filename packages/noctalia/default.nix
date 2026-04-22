{ pkgs, inputs, ... }:
if pkgs.stdenv.hostPlatform.isDarwin then
  pkgs.runCommandLocal "noctalia-unsupported-on-darwin" {
    meta.platforms = pkgs.lib.platforms.linux;
  } "mkdir -p $out"
else
  inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
    inherit pkgs;
    settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
  }
