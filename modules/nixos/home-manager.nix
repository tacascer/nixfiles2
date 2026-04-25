{ inputs, config, lib, ... }:
let
  cfg = config.custom.homeManager;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.custom.homeManager = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "tacascer";
      description = "Primary Home Manager user configured by shared NixOS modules.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "25.11";
      description = "Home Manager state version for the shared user configuration.";
    };

    backupFileExtension = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "backup";
      description = "Extension used when Home Manager needs to back up colliding files.";
    };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = cfg.backupFileExtension;

    home-manager.users.${cfg.username} = {
      home.stateVersion = cfg.stateVersion;
      home.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
      programs.home-manager.enable = true;
    };
  };
}
