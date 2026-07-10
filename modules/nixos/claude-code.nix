{
  flake,
  config,
  inputs,
  lib,
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
  ohMyClaudecodePackage = llmAgentsPackages.oh-my-claudecode;
  claudeCodeMdManagementPlugin = "${claudePluginsOfficial}/plugins/claude-md-management";
  claudeCodeOhMyClaudecodePlugin = "${ohMyClaudecodePackage}/lib/node_modules/oh-my-claude-sisyphus";
  claudeCodeStatusLineCommand = "${lib.getExe pkgs.nodejs} ${ohMyClaudecodePackage}/lib/node_modules/oh-my-claude-sisyphus/dist/hud/index.js";
in
{
  home-manager.extraSpecialArgs = {
    claudeCodePackage = claudeCodePackage;
    claudeCodeClaudeMd = ../home/claude-home-instructions.md;
    claudeCodeMdManagementPlugin = claudeCodeMdManagementPlugin;
    claudeCodeOhMyClaudecodePlugin = claudeCodeOhMyClaudecodePlugin;
    claudeCodeStatusLineCommand = claudeCodeStatusLineCommand;
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
