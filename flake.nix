{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:epireyn/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";

    wallpkgs.url = "github:NotAShelf/wallpkgs";
    nvf.url = "github:notashelf/nvf";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    qmd = {
      url = "github:tobi/qmd/v2.5.3";
      flake = false;
    };
    tmux-nerd-font-window-name = {
      url = "github:joshmedeski/tmux-nerd-font-window-name";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-mem = {
      url = "github:thedotmack/claude-mem";
      flake = false;
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
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
