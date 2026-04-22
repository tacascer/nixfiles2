{ pkgs, lib, inputs, system, ... }:
let
  unfreePkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.wrapper-modules.wrappers.claude-code.wrap {
  pkgs = unfreePkgs;
  flags = {
    "--append-system-prompt" = builtins.readFile ./claude-home-instructions.md;
  };
  settings = {
    includeCoAuthoredBy = false;
    enabledPlugins = {
      # "claude-mem@thedotmack" = false;
      # "superpowers@claude-plugins-official" = false;
      "claude-md-management@claude-plugins-official" = true;
      "oh-my-claudecode@omc" = true;
    };
    extraKnownMarketplaces = {
      # thedotmack.source = {
      #   source = "github";
      #   repo = "thedotmack/claude-mem";
      # };
      omc.source = {
        source = "git";
        url = "https://github.com/Yeachan-Heo/oh-my-claudecode.git";
      };
    };
    skipDangerousModePermissionPrompt = true;
    env = {
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    };
    statusLine = {
      type = "command";
      command = "${lib.getExe pkgs.nodejs} ${inputs.oh-my-claudecode}/dist/hud/index.js";
    };
  };
  pluginDirs = [
    "${inputs.oh-my-claudecode}"
    # "${inputs.claude-mem}/plugin"
    # "${inputs.superpowers}"
    "${inputs.claude-plugins-official}/plugins/claude-md-management"
  ];
  envDefault = {
    CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
  };
}
