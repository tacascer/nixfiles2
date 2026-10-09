{
  opencodePackage,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = opencodePackage;
    context = ./agent-home-instructions.md;
  };
}
