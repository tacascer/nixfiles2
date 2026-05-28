{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.pi;
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  piPackage = llmAgentsPackages.pi;
  username = config.custom.homeManager.username;

  defaultSettings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.5";
    defaultThinkingLevel = "medium";
    enableSkillCommands = true;

    # Make Pi package installs use the Nix-provided npm instead of relying on a
    # mutable global npm installation.
    npmCommand = [ "${pkgs.nodejs}/bin/npm" ];

    # Pi packages bundle extensions, skills, prompts, and themes. Pi will
    # install missing package contents under ~/.pi/agent/npm on startup.
    packages = cfg.packages;
  };

  appendSystemPrompt = ''
    ## Repository worktree safety

    Before making any code changes in a git repository, create and work from a
    dedicated `git worktree` branch instead of editing the main checkout
    directly.

    ## Local delegation and context isolation preference

    When work can be parallelized, delegated, run in the background, or isolated
    from the main context as a well-defined subtask, prefer pi-subagents over
    keeping detailed exploration, implementation, review, or validation work in
    the parent conversation. Context-isolated subtasks are bounded tasks whose
    detailed logs or intermediate reasoning would unnecessarily pollute the main
    context. Use `Agent` with a self-contained prompt to start each subagent,
    choose an appropriate `subagent_type` for the role when available, and use
    background mode for long-running independent work. Use `get_subagent_result`
    with waiting enabled to retrieve background results, and `steer_subagent` to
    redirect a running subagent when needed. Read an explicit final status/report
    from every delegated subagent before relying on or summarizing its work.
    Avoid delegation for vague tasks, tasks requiring ongoing user interaction,
    or tasks tightly coupled to the parent agent's current reasoning.
  '';
in
{
  options.custom.pi = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "npm:@juicesharp/rpiv-todo@1.12.0"
        "git:github.com/juicesharp/rpiv-ask-user-question@8dfafc868a412e3cc63f06773b0fbc8c066d5f9f"
        "npm:pi-web-access@0.10.7"
        "npm:@samfp/pi-memory@1.3.2"
        "npm:@tintinweb/pi-subagents@0.8.0"
        "npm:context-mode@1.0.151"
      ];
      description = "Pi packages to load declaratively from generated settings.json.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra Pi settings merged into ~/.pi/agent/settings.json.";
    };
  };

  config = {
    environment.systemPackages = [
      piPackage
      pkgs.nodejs
    ];

    home-manager.users.${username}.home.file = {
      ".pi/agent/settings.json".text = builtins.toJSON (defaultSettings // cfg.settings);
      ".pi/agent/APPEND_SYSTEM.md".text = appendSystemPrompt;
      ".pi/agent/extensions/git-checkpoint.ts".source = ./extensions/git-checkpoint.ts;
      ".pi/agent/extensions/git-worktree-session.ts".source = ./extensions/git-worktree-session.ts;
      ".pi/agent/skills/brainstorming".source = ./skills/brainstorming;
      ".pi/agent/skills/nixos-pi-declarative".source = ./skills/nixos-pi-declarative;
      ".pi/agent/skills/post-brainstorming-implementation".source = ./skills/post-brainstorming-implementation;
      ".pi/agent/skills/pi-writing-plans".source = ./skills/pi-writing-plans;
      ".pi/agent/skills/pi-subagent-driven-development".source = ./skills/pi-subagent-driven-development;
      ".pi/agent/skills/pi-finishing-development-branch".source = ./skills/pi-finishing-development-branch;
      ".pi/agent/skills/child-pi-explorer".source = ./skills/child-pi-explorer;
      ".pi/agent/skills/child-pi-implementer".source = ./skills/child-pi-implementer;
      ".pi/agent/skills/child-pi-spec-reviewer".source = ./skills/child-pi-spec-reviewer;
      ".pi/agent/skills/child-pi-code-quality-reviewer".source = ./skills/child-pi-code-quality-reviewer;
      ".pi/agent/skills/child-pi-validation-analyst".source = ./skills/child-pi-validation-analyst;
    };
  };
}
