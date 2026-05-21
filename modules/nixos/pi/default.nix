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

  piSubagentPane = pkgs.writeShellApplication {
    name = "pi-subagent-pane";
    runtimeInputs = [
      piPackage
      pkgs.coreutils
      pkgs.tmux
    ];
    text = ''
      if [[ -z "''${TMUX:-}" ]]; then
        echo "pi-subagent-pane must be run from inside tmux." >&2
        exit 1
      fi

      if [[ $# -gt 0 ]]; then
        prompt="$*"
      else
        prompt="$(cat)"
      fi

      if [[ -z "$prompt" ]]; then
        printf '%s\n' "usage: pi-subagent-pane <task prompt>" >&2
        printf '%s\n' "       printf '%s\\n' '<task prompt>' | pi-subagent-pane" >&2
        exit 1
      fi

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/pi-subagent-panes"
      mkdir -p "$state_dir"
      prompt_file="$(mktemp "$state_dir/task.XXXXXX.md")"
      output_file="$(mktemp "$state_dir/output.XXXXXX.md")"
      printf '%s\n' "$prompt" > "$prompt_file"

      title="pi-subagent"
      cmd="cd $(printf '%q' "$PWD"); pi -p @$(printf '%q' "$prompt_file") 2>&1 | tee $(printf '%q' "$output_file"); printf '\\n[pi-subagent-pane] output: %s\\n[pi-subagent-pane] prompt: %s\\n' $(printf '%q' "$output_file") $(printf '%q' "$prompt_file"); exec \"''${SHELL:-bash}\""

      tmux split-window -h -c "$PWD" -T "$title" "$cmd"
      tmux display-message "spawned pi subagent pane; output: $output_file"
      printf '%s\n' "$output_file"
    '';
  };

  appendSystemPrompt = ''
    ## Local delegation preference

    When the user asks you to spawn or delegate to subagents and you are running
    inside tmux, prefer observable tmux panes over hidden background work.
    Use `pi-subagent-pane` to start each independent subagent in its own tmux
    pane, passing a self-contained task prompt. Capture the output path printed
    by the command, continue your own work, then read the output file when you
    need the result. If tmux is unavailable or the user explicitly asks for the
    subagent extension, use the normal available subagent tools instead.
  '';
in
{
  options.custom.pi = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "npm:pi-subagents@0.25.0"
        "npm:@juicesharp/rpiv-todo@1.12.0"
        "git:github.com/juicesharp/rpiv-ask-user-question@8dfafc868a412e3cc63f06773b0fbc8c066d5f9f"
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
      piSubagentPane
      pkgs.nodejs
    ];

    home-manager.users.${username}.home.file = {
      ".pi/agent/settings.json".text = builtins.toJSON (defaultSettings // cfg.settings);
      ".pi/agent/APPEND_SYSTEM.md".text = appendSystemPrompt;
      ".pi/agent/skills/nixos-pi-declarative".source = ./skills/nixos-pi-declarative;
      ".pi/agent/skills/tmux-subagent-panes/SKILL.md".text = ''
        ---
        name: tmux-subagent-panes
        description: Use when delegating work to subagents from Pi, especially when the user asks for subagents in separate tmux panes or observable parallel work.
        ---

        # Tmux Subagent Panes

        When spawning subagents from inside tmux, prefer visible tmux panes so the user can observe and interact with each child agent.

        ## Command

        Use the declarative helper:

        ```bash
        pi-subagent-pane "<self-contained subagent task>"
        ```

        For multiline prompts:

        ```bash
        cat <<'EOF' | pi-subagent-pane
        <self-contained subagent task>
        EOF
        ```

        The helper:
        - creates a new tmux pane in the current working directory
        - runs `pi -p` with the prompt in that pane
        - tees the child output to a temp file
        - prints the output file path to the parent pane

        Continue your own work while panes run. Read the printed output files when you need results.

        If not inside tmux, or if the user specifically wants the `pi-subagents` extension, use the normal subagent tool instead.
      '';
    };
  };
}
