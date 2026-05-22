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

  piInstancePane = pkgs.writeShellApplication {
    name = "pi-instance-pane";
    runtimeInputs = [
      piPackage
      pkgs.coreutils
      pkgs.tmux
    ];
    text = ''
      if [[ -z "''${TMUX:-}" ]]; then
        echo "pi-instance-pane must be run from inside tmux." >&2
        exit 1
      fi

      if [[ $# -gt 0 ]]; then
        prompt="$*"
      else
        prompt="$(cat)"
      fi

      if [[ -z "$prompt" ]]; then
        printf '%s\n' "usage: pi-instance-pane <task prompt>" >&2
        printf '%s\n' "       printf '%s\\n' '<task prompt>' | pi-instance-pane" >&2
        exit 1
      fi

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/pi-instance-panes"
      mkdir -p "$state_dir"
      prompt_file="$(mktemp "$state_dir/task.XXXXXX.md")"
      output_file="$(mktemp "$state_dir/output.XXXXXX.md")"
      printf '%s\n' "$prompt" > "$prompt_file"

      title="pi-instance"
      env_exports="export PI_PARENT_OUTPUT_FILE=$(printf '%q' "$output_file"); "
      for name in PI_PARENT_JOB_ID PI_PARENT_EVENT_FILE; do
        if [[ -n "''${!name:-}" ]]; then
          env_exports+="export $name=$(printf '%q' "''${!name}"); "
        fi
      done

      cmd="$env_exports cd $(printf '%q' "$PWD"); pi -p @$(printf '%q' "$prompt_file") 2>&1 | tee $(printf '%q' "$output_file"); printf '\\n[pi-instance-pane] output: %s\\n[pi-instance-pane] prompt: %s\\n' $(printf '%q' "$output_file") $(printf '%q' "$prompt_file"); exec \"''${SHELL:-bash}\""

      tmux split-window -h -c "$PWD" -T "$title" "$cmd"
      tmux display-message "spawned pi instance pane; output: $output_file"
      printf '%s\n' "$output_file"
    '';
  };

  appendSystemPrompt = ''
    ## Repository worktree safety

    Before making any code changes in a git repository, create and work from a
    dedicated `git worktree` branch instead of editing the main checkout
    directly.

    ## Local delegation preference

    When work can be parallelized, delegated, or run in the background and you
    are running inside tmux, prefer observable tmux panes over hidden background
    work. Use `pi-instance-pane` to start each independent Pi instance in its
    own tmux pane, passing a self-contained task prompt. Capture the output path
    printed by the command, continue your own work, then read the output file
    when you need the result. If tmux is unavailable, use the normal available
    background-work mechanisms instead.
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
      piInstancePane
      pkgs.nodejs
    ];

    home-manager.users.${username}.home.file = {
      ".pi/agent/settings.json".text = builtins.toJSON (defaultSettings // cfg.settings);
      ".pi/agent/APPEND_SYSTEM.md".text = appendSystemPrompt;
      ".pi/agent/extensions/git-checkpoint.ts".source = ./extensions/git-checkpoint.ts;
      ".pi/agent/extensions/permission-gate.ts".source = ./extensions/permission-gate.ts;
      ".pi/agent/extensions/tmux-pi-instance-panes.ts".source = ./extensions/tmux-pi-instance-panes.ts;
      ".pi/agent/skills/nixos-pi-declarative".source = ./skills/nixos-pi-declarative;
    };
  };
}
