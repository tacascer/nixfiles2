{
  config,
  lib,
  codexPackage,
  codexSuperpowersPlugin,
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
  programs.codex = {
    enable = true;
    package = codexPackage;
    plugins = [ codexSuperpowersPlugin ];
    settings = {
      model_reasoning_effort = "medium";
      developer_instructions = "When writing git commits, use conventional commits.";

      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      model = "gpt-6";
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
