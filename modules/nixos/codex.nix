{
  flake,
  config,
  pkgs,
  ...
}:
let
  omxPackage = flake.packages.${pkgs.stdenv.hostPlatform.system}.omx;
  omxHookCommand =
    "${pkgs.nodejs}/bin/node ${omxPackage}/lib/node_modules/oh-my-codex/dist/scripts/codex-native-hook.js";

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
  agentsFile = omxPackage + "/lib/node_modules/oh-my-codex/templates/AGENTS.md";
in
{
  config = {
    home-manager.extraSpecialArgs = {
      codexHooksFile = hooksFile;
      codexContextFile = agentsFile;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.codex
    ];
  };
}
