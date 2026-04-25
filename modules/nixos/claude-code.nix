{
  flake,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home-manager.extraSpecialArgs = {
    claudeCodeClaudeMd = ../home/claude-home-instructions.md;
    claudeCodeMdManagementPlugin = "${inputs.claude-plugins-official}/plugins/claude-md-management";
    claudeCodeOhMyClaudecodePlugin = inputs.oh-my-claudecode;
    claudeCodeStatusLineCommand = "${lib.getExe pkgs.nodejs} ${inputs.oh-my-claudecode}/dist/hud/index.js";
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
