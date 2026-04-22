{ flake, lib, config, pkgs, ... }:
let
  cfg = config.custom.codex;

  defaultSettings = {
    model = "o4-mini";
    model_provider = "openai";
    approval_policy = "on-request";
    sandbox_mode = "read-only";
    web_search = "cached";
    features = {
      shell_tool = true;
    };
    history = {
      persistence = "save-all";
    };
    analytics = {
      enabled = false;
    };
  };

  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "codex-config.toml" cfg.settings;
in
{
  options.custom.codex = {
    settings = lib.mkOption {
      type = tomlFormat.type;
      default = defaultSettings;
      description = "Codex config.toml settings as a Nix attrset. Maps directly to TOML.";
    };
  };

  config = {
    home-manager.extraSpecialArgs = {
      codexConfigFile = configFile;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.codex
    ];
  };
}
