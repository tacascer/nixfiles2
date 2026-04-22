{ pkgs }:
let
  tomlFormat = pkgs.formats.toml { };
in
rec {
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

  mkConfigFile = settings: tomlFormat.generate "codex-config.toml" settings;

  # Codex writes runtime state (SQLite, logs, credentials) to CODEX_HOME,
  # so it cannot point to a read-only Nix store path. The wrapper seeds a
  # default config.toml into CODEX_HOME only when one does not already exist,
  # which keeps first-run setup declarative without clobbering OMX-managed or
  # user-managed config changes later.
  mkWrapped =
    {
      binName,
      extraArgs ? "",
      settings ? defaultSettings,
    }:
    let
      configFile = mkConfigFile settings;
    in
    pkgs.writeShellScriptBin binName ''
      codex_home="''${CODEX_HOME:-$HOME/.codex}"
      mkdir -p "$codex_home"
      if [ ! -e "$codex_home/config.toml" ]; then
        cp ${configFile} "$codex_home/config.toml"
      fi
      exec ${pkgs.codex}/bin/codex ${extraArgs} "$@"
    '';
}
