{ pkgs, ... }:
let
  common = import ./common.nix { inherit pkgs; };
in
common.mkWrapped {
  binName = "codex";
  settings = common.defaultSettings;
}
