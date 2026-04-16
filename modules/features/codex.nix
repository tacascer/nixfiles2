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
  # so it cannot point to a read-only Nix store path. Instead, the wrapper
  # copies the declarative config.toml into ~/.codex/ before launching codex.
  mkCodexWrapped =
    pkgs: settings:
    let
      configFile = mkConfigFile pkgs settings;
    in
    pkgs.writeShellScriptBin "codex" ''
      mkdir -p "$HOME/.codex"
      cp -f ${configFile} "$HOME/.codex/config.toml"
      exec ${pkgs.codex}/bin/codex "$@"
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
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.myCodex = mkCodexWrapped pkgs defaultSettings;
    };
}
