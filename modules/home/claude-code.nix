{
  config,
  lib,
  claudeCodePackage,
  claudeCodeClaudeMd,
  claudeCodeMdManagementPlugin,
  claudeCodeTestingPrinciplesPlugin,
  claudeCodeLoggingPrinciplesPlugin,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = claudeCodePackage;
    context = claudeCodeClaudeMd;
    plugins = {
      claude-md-management = claudeCodeMdManagementPlugin;
      testing-principles = claudeCodeTestingPrinciplesPlugin;
      logging-principles = claudeCodeLoggingPrinciplesPlugin;
    };
    settings = {
      includeCoAuthoredBy = false;
      enabledPlugins = {
        "claude-md-management@claude-plugins-official" = true;
      };
      skipDangerousModePermissionPrompt = true;
    };
  };

  # Keep manifest-relative skills inside the plugin root; the Home Manager
  # wrapper links component directories outside it, which Claude rejects.
  home.file."${config.programs.claude-code.configDir}/skills/logging-principles".source = lib.mkForce claudeCodeLoggingPrinciplesPlugin;

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
}
