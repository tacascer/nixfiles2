{
  claudeCodePackage,
  claudeCodeClaudeMd,
  claudeCodeMdManagementPlugin,
  claudeCodeTestingPrinciplesPlugin,
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
    };
    settings = {
      includeCoAuthoredBy = false;
      enabledPlugins = {
        "claude-md-management@claude-plugins-official" = true;
      };
      skipDangerousModePermissionPrompt = true;
    };
  };

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
}
