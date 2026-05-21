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
      cmd="cd $(printf '%q' "$PWD"); pi -p @$(printf '%q' "$prompt_file") 2>&1 | tee $(printf '%q' "$output_file"); printf '\\n[pi-instance-pane] output: %s\\n[pi-instance-pane] prompt: %s\\n' $(printf '%q' "$output_file") $(printf '%q' "$prompt_file"); exec \"''${SHELL:-bash}\""

      tmux split-window -h -c "$PWD" -T "$title" "$cmd"
      tmux display-message "spawned pi instance pane; output: $output_file"
      printf '%s\n' "$output_file"
    '';
  };

  appendSystemPrompt = ''
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
      ".pi/agent/skills/nixos-pi-declarative".source = ./skills/nixos-pi-declarative;
      ".pi/agent/skills/tmux-pi-instance-panes/SKILL.md".text = ''
        ---
        name: tmux-pi-instance-panes
        description: Use when parallel or background work should run in separate observable Pi tmux panes.
        ---

        # Tmux Pi Instance Panes

        When work can be parallelized, delegated, or run in the background from inside tmux, prefer visible tmux panes so the user can observe and interact with each spawned Pi instance.

        ## Command

        Use the declarative helper:

        ```bash
        pi-instance-pane "<self-contained task>"
        ```

        For multiline prompts:

        ```bash
        cat <<'EOF' | pi-instance-pane
        <self-contained task>
        EOF
        ```

        The helper:
        - creates a new tmux pane in the current working directory
        - runs `pi -p` with the prompt in that pane
        - tees the child output to a temp file
        - prints the output file path to the parent pane

        Continue your own work while panes run. Read the printed output files when you need results.

        If not inside tmux, use the normal available background-work mechanisms instead.
      '';
    };
  };
}
