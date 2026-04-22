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
      model = "o4-mini";
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
    };
    context = codexContextFile;
  };

  home.file.".codex/hooks.json".source = codexHooksFile;
}
