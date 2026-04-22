{
  config,
  lib,
  pkgs,
  omxPackage,
  codexTrustedProjectsRelativeToHome ? [ ],
  ...
}:
let
  homeDirectory = config.home.homeDirectory;

  resolveTrustedProjectPath =
    relativePath:
    let
      normalizedRelativePath = lib.removePrefix "./" (lib.removeSuffix "/" relativePath);
    in
    if normalizedRelativePath == "" || normalizedRelativePath == "." then
      homeDirectory
    else
      "${homeDirectory}/${normalizedRelativePath}";

  trustedProjects = builtins.listToAttrs (
    map (relativePath: {
      name = resolveTrustedProjectPath relativePath;
      value = {
        trust_level = "trusted";
      };
    }) codexTrustedProjectsRelativeToHome
  );

  omxHookCommand = "${pkgs.nodejs}/bin/node ${omxPackage}/lib/node_modules/oh-my-codex/dist/scripts/codex-native-hook.js";
  omxScriptsPath = "${omxPackage}/lib/node_modules/oh-my-codex/dist";

  defaultHooks = {
    hooks = {
      SessionStart = [
        {
          matcher = "startup|resume";
          hooks = [
            {
              type = "command";
              command = omxHookCommand;
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = omxHookCommand;
              statusMessage = "Running OMX Bash preflight";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          hooks = [
            {
              type = "command";
              command = omxHookCommand;
              statusMessage = "Running OMX tool review";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = omxHookCommand;
              statusMessage = "Applying OMX prompt routing";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = omxHookCommand;
              timeout = 30;
            }
          ];
        }
      ];
    };
  };

  jsonFormat = pkgs.formats.json { };
  hooksFile = jsonFormat.generate "codex-hooks.json" defaultHooks;
in
{
  programs.codex = {
    enable = true;
    package = pkgs.codex;
    settings = {
      notify = [
        "node"
        "${omxScriptsPath}/scripts/notify-hook.js"
      ];
      model_reasoning_effort = "medium";
      developer_instructions = "You have oh-my-codex installed. AGENTS.md is your orchestration brain and the main orchestration surface. Use skill/keyword routing like $name plus spawned role-specialized subagents for specialized work. Codex native subagents are available via .codex/agents and may be used for independent parallel subtasks within a single session or team pane. Skills are loaded from installed SKILL.md files under .codex/skills, not from native agent TOMLs. Use workflow skills via $name when explicitly invoked or clearly routed by AGENTS.md. Treat installed prompts as narrower internal execution surfaces under AGENTS.md authority, even when user-facing docs prefer $name keywords.";

      approval_policy = "on-request";
      model = "gpt-5.4";
      model_provider = "openai";
      sandbox_mode = "read-only";
      web_search = "cached";

      analytics.enabled = false;

      features = {
        shell_tool = true;
        multi_agent = true;
        child_agents_md = true;
        codex_hooks = true;
      };

      history.persistence = "save-all";

      env.USE_OMX_EXPLORE_CMD = "1";

      agents = {
        max_threads = 6;
        max_depth = 2;
      };

      mcp_servers = {
        omx_state = {
          command = "node";
          args = [ "${omxScriptsPath}/mcp/state-server.js" ];
          enabled = true;
          startup_timeout_sec = 5;
        };
        omx_memory = {
          command = "node";
          args = [ "${omxScriptsPath}/mcp/memory-server.js" ];
          enabled = true;
          startup_timeout_sec = 5;
        };
        omx_code_intel = {
          command = "node";
          args = [ "${omxScriptsPath}/mcp/code-intel-server.js" ];
          enabled = true;
          startup_timeout_sec = 10;
        };
        omx_trace = {
          command = "node";
          args = [ "${omxScriptsPath}/mcp/trace-server.js" ];
          enabled = true;
          startup_timeout_sec = 5;
        };
        omx_wiki = {
          command = "node";
          args = [ "${omxScriptsPath}/mcp/wiki-server.js" ];
          enabled = true;
          startup_timeout_sec = 5;
        };
      };

      projects = trustedProjects;

      tui.status_line = [
        "model-with-reasoning"
        "current-dir"
        "model-name"
        "context-remaining"
        "five-hour-limit"
        "weekly-limit"
        "used-tokens"
        "total-input-tokens"
        "total-output-tokens"
      ];
    };
    context = builtins.readFile "${omxPackage}/lib/node_modules/oh-my-codex/templates/AGENTS.md";
  };

  home.file.".codex/hooks.json".source = hooksFile;
}
