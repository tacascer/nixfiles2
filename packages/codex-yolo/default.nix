{ pkgs, ... }:
let
  common = import ../codex/common.nix { inherit pkgs; };
in
common.mkWrapped {
  binName = "codex-yolo";
  extraArgs = "--yolo";
  settings = common.defaultSettings;
}
