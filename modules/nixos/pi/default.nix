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

  piInstance = pkgs.writeShellApplication {
    name = "pi-instance";
    runtimeInputs = [
      piPackage
      pkgs.coreutils
      pkgs.tmux
    ];
    text = ''
      if [[ -z "''${TMUX:-}" ]]; then
        echo "pi-instance must be run from inside tmux." >&2
        exit 1
      fi

      if [[ $# -gt 0 ]]; then
        prompt="$*"
      else
        prompt="$(cat)"
      fi

      if [[ -z "$prompt" ]]; then
        printf '%s\n' "usage: pi-instance <task prompt>" >&2
        printf '%s\n' "       printf '%s\\n' '<task prompt>' | pi-instance" >&2
        exit 1
      fi

      base_state_dir="''${XDG_RUNTIME_DIR:-/tmp}/pi-instances"
      if [[ -n "''${PI_PARENT_JOB_ID:-}" ]]; then
        state_dir="$base_state_dir/$PI_PARENT_JOB_ID"
      else
        state_dir="$base_state_dir"
      fi
      mkdir -p "$state_dir"
      prompt_file="$(mktemp "$state_dir/task.XXXXXX.md")"
      output_file="$(mktemp "$state_dir/output.XXXXXX.md")"
      printf '%s\n' "$prompt" > "$prompt_file"

      if [[ -n "''${PI_PARENT_SESSION_ID:-}" ]]; then
        session_suffix="''${PI_PARENT_SESSION_ID:0:8}"
      else
        parent_tmux_session="$(tmux display-message -p '#S')"
        parent_tmux_pane="$(tmux display-message -p '#P')"
        session_suffix="$(printf '%s-%s' "$parent_tmux_session" "$parent_tmux_pane" | tr -cs '[:alnum:]_-' '-')"
      fi
      session_name="pi-instances-$session_suffix"

      if [[ -n "''${PI_PARENT_JOB_ID:-}" ]]; then
        window_suffix="''${PI_PARENT_JOB_ID:0:8}"
      else
        window_suffix="$(basename "$prompt_file" .md | cut -d. -f2)"
      fi
      window_name="pi-$window_suffix"
      env_exports="export PI_PARENT_OUTPUT_FILE=$(printf '%q' "$output_file"); "
      for name in PI_PARENT_SESSION_ID PI_PARENT_JOB_ID PI_PARENT_EVENT_FILE; do
        if [[ -n "''${!name:-}" ]]; then
          env_exports+="export $name=$(printf '%q' "''${!name}"); "
        fi
      done

      child_script="$env_exports cd $(printf '%q' "$PWD"); pi -p @$(printf '%q' "$prompt_file") 2>&1 | tee $(printf '%q' "$output_file"); exit \"''${PIPESTATUS[0]}\""
      cmd="${pkgs.bash}/bin/bash -lc $(printf '%q' "$child_script")"

      if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-window -d -t "$session_name" -n "$window_name" -c "$PWD" "$cmd"
      else
        tmux new-session -d -s "$session_name" -n "$window_name" -c "$PWD" "$cmd"
      fi
      tmux display-message "spawned pi instance window $window_name in session $session_name; output: $output_file"
      printf 'session=%s\n' "$session_name"
      printf 'window=%s\n' "$window_name"
      printf 'output=%s\n' "$output_file"
    '';
  };

  appendSystemPrompt = ''
    ## Repository worktree safety

    Before making any code changes in a git repository, create and work from a
    dedicated `git worktree` branch instead of editing the main checkout
    directly.

    ## Local delegation and context isolation preference

    When work can be parallelized, delegated, run in the background, or isolated
    from the main context as a well-defined subtask, and you are running inside
    tmux, prefer observable tmux windows over hidden background work or keeping
    the details in the parent conversation. Context-isolated subtasks are bounded
    tasks whose detailed exploration, logs, or intermediate reasoning would
    unnecessarily pollute the main context. Use `spawn_pi_instance` to start each
    independent Pi instance in a new window inside the tmux session scoped to the
    current parent Pi session, passing a self-contained task prompt. Good
    candidates include focused research, inspection, validation, or implementation
    subtasks. Avoid spawning for vague tasks, tasks requiring ongoing user
    interaction, or tasks tightly coupled to the parent agent's current reasoning.
    Capture the returned output and event paths, continue your own work when
    appropriate, then read the event or output file before relying on the result.
    If tmux is unavailable, use the normal available mechanisms instead.
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
      piInstance
      pkgs.nodejs
    ];

    home-manager.users.${username}.home.file = {
      ".pi/agent/settings.json".text = builtins.toJSON (defaultSettings // cfg.settings);
      ".pi/agent/APPEND_SYSTEM.md".text = appendSystemPrompt;
      ".pi/agent/extensions/git-checkpoint.ts".source = ./extensions/git-checkpoint.ts;
      ".pi/agent/extensions/git-worktree-session.ts".source = ./extensions/git-worktree-session.ts;
      ".pi/agent/extensions/tmux-pi-instances.ts".source = ./extensions/tmux-pi-instances.ts;
      ".pi/agent/skills/brainstorming".source = ./skills/brainstorming;
      ".pi/agent/skills/nixos-pi-declarative".source = ./skills/nixos-pi-declarative;
      ".pi/agent/skills/post-brainstorming-implementation".source = ./skills/post-brainstorming-implementation;
      ".pi/agent/skills/child-pi-explorer".source = ./skills/child-pi-explorer;
      ".pi/agent/skills/child-pi-implementer".source = ./skills/child-pi-implementer;
      ".pi/agent/skills/child-pi-spec-reviewer".source = ./skills/child-pi-spec-reviewer;
      ".pi/agent/skills/child-pi-code-quality-reviewer".source = ./skills/child-pi-code-quality-reviewer;
      ".pi/agent/skills/child-pi-validation-analyst".source = ./skills/child-pi-validation-analyst;
    };
  };
}
