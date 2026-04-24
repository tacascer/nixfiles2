{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    nvf.url = "github:notashelf/nvf";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-colors.url = "github:misterio77/nix-colors";
    omx = {
      url = "github:Yeachan-Heo/oh-my-codex/56c93fd3daed9f6043f0bbb65476d355d47083c5";
      flake = false;
    };
    tmux-nerd-font-window-name = {
      url = "github:joshmedeski/tmux-nerd-font-window-name";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oh-my-claudecode = {
      url = "github:Yeachan-Heo/oh-my-claudecode";
      flake = false;
    };
    claude-mem = {
      url = "github:thedotmack/claude-mem";
      flake = false;
    };
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    "oh-my-openagent" = {
      url = "github:code-yeongyu/oh-my-openagent?ref=dev";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
