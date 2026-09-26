{
  config,
  lib,
  claudeCodePackage,
  claudeCodeClaudeMd,
  claudeCodeMdManagementPlugin,
  claudeCodeTestingPrinciplesPlugin,
  claudeCodeDesignObservabilityPlugin,
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
      design-observability = claudeCodeDesignObservabilityPlugin;
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
  home.file."${config.programs.claude-code.configDir}/skills/design-observability".source = lib.mkForce claudeCodeDesignObservabilityPlugin;

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
}
