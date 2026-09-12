{
  flake,
  config,
  inputs,
  pkgs,
  ...
}:
let
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  claudeCodePackage = llmAgentsPackages.claude-code;
  claudePluginsOfficial = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "119f4ebf21f6b932627e26824a7cae073c441fea";
    hash = "sha256-xW0jueSpMcPp7XGLWHVFsusapKnlFCrz6kRTtWPhAVc=";
  };
  claudeCodeMdManagementPlugin = "${claudePluginsOfficial}/plugins/claude-md-management";
in
{
  home-manager.extraSpecialArgs = {
    claudeCodePackage = claudeCodePackage;
    claudeCodeTestingPrinciplesPlugin = "${inputs.ai-plugins}/plugins/testing-principles";
    claudeCodeClaudeMd = ../home/claude-home-instructions.md;
    claudeCodeMdManagementPlugin = claudeCodeMdManagementPlugin;
  };

  home-manager.users.${config.custom.homeManager.username}.imports = [
    flake.homeModules."claude-code"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    shellAliases = {
      claude-yolo = "claude --dangerously-skip-permissions";
    };
  };
}
