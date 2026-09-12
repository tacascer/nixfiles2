{
  config,
  lib,
  codexPackage,
  codexSuperpowersPlugin,
  codexTestingPrinciplesPlugin,
  codexTrustedProjectsRelativeToHome ? [ ],
  ...
}:
let
  homeDirectory = config.home.homeDirectory;

  resolveTrustedProjectPath =
    relativePath:
    let
      normalizedRelativePath = lib.removePrefix "./" (lib.removeSuffix "/" relativePath);
    in
    if normalizedRelativePath == "" || normalizedRelativePath == "." then
      homeDirectory
    else
      "${homeDirectory}/${normalizedRelativePath}";

  trustedProjects = builtins.listToAttrs (
    map (relativePath: {
      name = resolveTrustedProjectPath relativePath;
      value = {
        trust_level = "trusted";
      };
    }) codexTrustedProjectsRelativeToHome
  );

in
{
  # Codex 0.154 ignores symlinked version directories when finding installed plugins.
  # Link each top-level entry instead, keeping the version directory real and
  # skill directories symlinked as required by the skill loader.
  home.file = lib.mkMerge (
    map (
      plugin:
      let
        manifest = builtins.fromJSON (builtins.readFile "${plugin}/.codex-plugin/plugin.json");
        cachePath = ".codex/plugins/cache/home-manager/${manifest.name}/${manifest.version}";
      in
      {
        "${cachePath}".enable = false;
      }
      // lib.mapAttrs' (
        name: _:
        lib.nameValuePair "${cachePath}/${name}" {
          source = "${plugin}/${name}";
        }
      ) (builtins.readDir plugin)
    ) config.programs.codex.plugins
  );

  home.activation.migrateCodexPluginDirectories = lib.hm.dag.entryBefore [ "checkLinkTargets" ] (
    lib.concatMapStringsSep "\n" (
      plugin:
      let
        manifest = builtins.fromJSON (builtins.readFile "${plugin}/.codex-plugin/plugin.json");
        cachePath = "${homeDirectory}/.codex/plugins/cache/home-manager/${manifest.name}/${manifest.version}";
      in
      ''
        if [[ -L ${lib.escapeShellArg cachePath} && $(readlink ${lib.escapeShellArg cachePath}) == /nix/store/* ]]; then
          run unlink ${lib.escapeShellArg cachePath}
        fi
      ''
    ) config.programs.codex.plugins
  );

  programs.codex = {
    enable = true;
    package = codexPackage;
    plugins = [
      codexSuperpowersPlugin
      codexTestingPrinciplesPlugin
    ];
    settings = {
      model_reasoning_effort = "medium";
      developer_instructions = "When writing git commits, use conventional commits.";

      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      model = "gpt-6-astra";
      model_provider = "openai";
      sandbox_mode = "read-only";
      web_search = "cached";

      analytics.enabled = false;

      features = {
        shell_tool = true;
        multi_agent = true;
        child_agents_md = true;
      };

      history.persistence = "save-all";

      agents = {
        max_threads = 6;
        max_depth = 2;
      };

      projects = trustedProjects;

      tui.status_line = [
        "model-with-reasoning"
        "current-dir"
        "model-name"
        "context-remaining"
        "five-hour-limit"
        "weekly-limit"
        "used-tokens"
        "total-input-tokens"
        "total-output-tokens"
      ];
    };
  };
}
