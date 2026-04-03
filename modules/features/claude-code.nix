{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.claude-code =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myClaudeCode
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myClaudeCode = inputs.wrapper-modules.wrappers.claude-code.wrap {
        pkgs = import inputs.nixpkgs {
          inherit (pkgs.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
        settings = {
          includeCoAuthoredBy = false;
          enabledPlugins = {
            "claude-mem@thedotmack" = true;
            "superpowers@claude-plugins-official" = false;
            "claude-md-management@claude-plugins-official" = true;
            "oh-my-claudecode@omc" = true;
          };
          extraKnownMarketplaces = {
            thedotmack.source = {
              source = "github";
              repo = "thedotmack/claude-mem";
            };
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
            command = "node ${inputs.oh-my-claudecode}/dist/hud/index.js";
          };
        };
        pluginDirs = [
          "${inputs.oh-my-claudecode}"
          "${inputs.claude-mem}/plugin"
          "${inputs.superpowers}"
          "${inputs.claude-plugins-official}/plugins/claude-md-management"
        ];
        envDefault = {
          CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "true";
        };
      };
    };
}
