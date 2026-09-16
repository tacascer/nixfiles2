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
  # Codex 0.154 loads local marketplace installations from the "local" cache
  # and ignores symlinked plugin manifests. Materialize the pinned sources there
  # after Home Manager has linked its versioned marketplace sources.
  home.activation.installCodexLocalPlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    lib.concatMapStringsSep "\n" (
      plugin:
      let
        manifest = builtins.fromJSON (builtins.readFile "${plugin}/.codex-plugin/plugin.json");
        cachePath = "${homeDirectory}/.codex/plugins/cache/home-manager/${manifest.name}/local";
      in
      ''
        run rm -rf -- ${lib.escapeShellArg cachePath}
        run mkdir -p -- ${lib.escapeShellArg cachePath}
        run cp -RL --no-preserve=mode -- ${lib.escapeShellArg "${plugin}/."} ${lib.escapeShellArg cachePath}
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
        memories = true;
      };

      memories = {
        generate_memories = true;
        use_memories = true;
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
