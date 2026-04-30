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
  claudePluginsPackage = llmAgentsPackages.claude-plugins;
  ohMyClaudecodePackage = llmAgentsPackages.oh-my-claudecode;
  claudeCodeMdManagementPlugin = "${claudePluginsPackage}/plugins/claude-md-management";
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
