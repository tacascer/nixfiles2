{ config, lib, ... }:
let
  cfg = config.custom.bash;
in
{
  options.custom.bash = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      description = "Path to the flake directory.";
    };
  };

  config.programs.starship = {
    enable = true;
    presets = [ "gruvbox-rainbow" ];
  };

  config.programs.bash = {
    completion.enable = true;
    interactiveShellInit = ''
      if [ -r "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi
    '';
    shellAliases = {
      nrbs = "sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
      nrbsu = "sudo nix flake update --flake ${cfg.flakeDir} && sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
    };
  };

  # enable /bin/bash compatibility
  config.services.envfs.enable = true;
}
