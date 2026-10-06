{
  opencodePackage,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = opencodePackage;
    context = ./claude-home-instructions.md;
  };
}
