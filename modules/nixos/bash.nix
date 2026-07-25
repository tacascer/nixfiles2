{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.bash;
  starshipPresets = {
    gruvbox = "gruvbox-rainbow";
    tokyo-night-storm = "tokyo-night";
  };
in
{
  options.custom.bash = {
    flakeDir = lib.mkOption {
      type = lib.types.str;
      description = "Path to the flake directory.";
    };
  };

  config = {
    programs.bash = {
      completion.enable = true;
      interactiveShellInit = ''
        if [ -r "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
          . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
        fi
      '';
    };

    programs.starship.enable = false;

    home-manager.users.${config.custom.homeManager.username} = {
      imports = [ flake.homeModules.bash ];

      programs.bash.shellAliases = {
        nrbs = "sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
        nrbsu = "sudo nix flake update --flake ${cfg.flakeDir} && sudo nixos-rebuild switch --flake ${cfg.flakeDir}";
      };

      programs.starship.presets = [ starshipPresets.${config.custom.theme} ];
    };

    # Enable /bin/bash compatibility.
    services.envfs.enable = true;
  };
}
