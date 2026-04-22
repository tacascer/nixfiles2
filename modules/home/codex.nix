{
  pkgs,
  codexHooksFile,
  codexContextFile,
  ...
}:
{
  programs.codex = {
    enable = true;
    package = pkgs.codex;
    settings = {
      model_provider = "openai";
      approval_policy = "on-request";
      sandbox_mode = "read-only";
      web_search = "cached";
      features = {
        shell_tool = true;
      };
      history = {
        persistence = "save-all";
      };
      analytics = {
        enabled = false;
      };
      tui = {
        status_line = [
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
    };
    context = codexContextFile;
  };

  home.file.".codex/hooks.json".source = codexHooksFile;
}
