{
  opencodePackage,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = opencodePackage;
    context = ./claude-home-instructions.md;
    settings.plugin = [
      "superpowers@git+https://github.com/obra/superpowers.git"
    ];
  };
}
