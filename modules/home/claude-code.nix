{
  claudeCodePackage,
  claudeCodeClaudeMd,
  claudeCodeMdManagementPlugin,
  claudeCodeOhMyClaudecodePlugin,
  claudeCodeStatusLineCommand,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = claudeCodePackage;
    context = claudeCodeClaudeMd;
    plugins = [
      claudeCodeOhMyClaudecodePlugin
      claudeCodeMdManagementPlugin
    ];
    settings = {
      includeCoAuthoredBy = false;
      enabledPlugins = {
        "claude-md-management@claude-plugins-official" = true;
        "oh-my-claudecode@omc" = true;
      };
      extraKnownMarketplaces = {
        omc.source = {
          source = "git";
          url = "https://github.com/Yeachan-Heo/oh-my-claudecode.git";
        };
      };
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = claudeCodeStatusLineCommand;
      };
    };
  };

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
}
