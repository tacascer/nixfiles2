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
      instructions = ''
        When you write or edit git commit messages, use semantic commits (Conventional Commits).
        Format commit subjects like: type(scope): summary
        Use common types like feat, fix, docs, refactor, test, chore, and style.
      '';
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
