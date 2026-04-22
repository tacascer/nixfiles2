# Custom wrapper for OpenAI Codex CLI using wrapPackage (no pre-built wrapper
# exists in nix-wrapper-modules, unlike git/claude-code/alacritty).
{
  self,
  inputs,
  ...
}:
let
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

  mkConfigFile =
    pkgs: settings:
    let
      tomlFormat = pkgs.formats.toml { };
    in
    tomlFormat.generate "codex-config.toml" settings;

  # Codex writes runtime state (SQLite, logs, credentials) to CODEX_HOME,
  # so it cannot point to a read-only Nix store path. The wrapper seeds a
  # default config.toml into CODEX_HOME only when one does not already exist,
  # which keeps first-run setup declarative without clobbering OMX-managed or
  # user-managed config changes later.
  mkCodexWrapped =
    pkgs: settings:
    let
      configFile = mkConfigFile pkgs settings;
    in
    pkgs.writeShellScriptBin "codex" ''
      codex_home="''${CODEX_HOME:-$HOME/.codex}"
      mkdir -p "$codex_home"
      if [ ! -e "$codex_home/config.toml" ]; then
        cp ${configFile} "$codex_home/config.toml"
      fi
      exec ${pkgs.codex}/bin/codex "$@"
    '';

  mkCodexYoloWrapped =
    pkgs: settings:
    let
      configFile = mkConfigFile pkgs settings;
    in
    pkgs.writeShellScriptBin "codex-yolo" ''
      codex_home="''${CODEX_HOME:-$HOME/.codex}"
      mkdir -p "$codex_home"
      if [ ! -e "$codex_home/config.toml" ]; then
        cp ${configFile} "$codex_home/config.toml"
      fi
      exec ${pkgs.codex}/bin/codex --yolo "$@"
    '';
in
{
  flake.nixosModules.codex =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.custom.codex;
    in
    {
      options.custom.codex = {
        settings = lib.mkOption {
          type = (pkgs.formats.toml { }).type;
          default = defaultSettings;
          description = "Codex config.toml settings as a Nix attrset. Maps directly to TOML.";
        };
      };

      config.environment.systemPackages = [
        (mkCodexWrapped pkgs cfg.settings)
        (mkCodexYoloWrapped pkgs cfg.settings)
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.myCodex = mkCodexWrapped pkgs defaultSettings;
      packages.myCodexYolo = mkCodexYoloWrapped pkgs defaultSettings;
    };
}
