{ pkgs, codexConfigFile, ... }:
{
  home.packages = [ pkgs.codex ];

  home.file.".codex/config.toml".source = codexConfigFile;
}
