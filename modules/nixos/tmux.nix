{
  flake,
  config,
  inputs,
  pkgs,
  ...
}:
{
  home-manager.extraSpecialArgs.tmuxNerdFontWindowName =
    inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default;

  home-manager.users.${config.custom.homeManager.username}.imports = [
    flake.homeModules.tmux
  ];
}
