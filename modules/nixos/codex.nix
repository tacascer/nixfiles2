# Custom wrapper for OpenAI Codex CLI using wrapPackage (no pre-built wrapper
# exists in nix-wrapper-modules, unlike git/claude-code/alacritty).
{ pkgs, lib, config, ... }:
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

  mkConfigFile =
    settings:
    let
      tomlFormat = pkgs.formats.toml { };
    in
    tomlFormat.generate "codex-config.toml" settings;

  mkCodexWrapped =
    binaryName: extraArgs: settings:
    let
      configFile = mkConfigFile settings;
    in
    pkgs.writeShellScriptBin binaryName ''
      codex_home="''${CODEX_HOME:-$HOME/.codex}"
      mkdir -p "$codex_home"
      if [ ! -e "$codex_home/config.toml" ]; then
        cp ${configFile} "$codex_home/config.toml"
      fi
      exec ${pkgs.codex}/bin/codex ${extraArgs} "$@"
    '';
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
    (mkCodexWrapped "codex" "" cfg.settings)
    (mkCodexWrapped "codex-yolo" "--yolo" cfg.settings)
  ];
}
