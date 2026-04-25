{
  pkgs,
  lib,
  perSystem,
  ...
}:
let
  # Title-case a hyphenated string: "close-window" → "Close Window"
  titleCase =
    s:
    let
      words = lib.splitString "-" s;
      capitalize =
        w: (lib.toUpper (builtins.substring 0 1 w)) + builtins.substring 1 (builtins.stringLength w - 1) w;
    in
    builtins.concatStringsSep " " (map capitalize words);

  # Extract a human-readable label from a spawn command value
  spawnLabel =
    actionValue:
    let
      str = builtins.toString actionValue;
      firstWord = builtins.head (lib.splitString " " str);
    in
    titleCase (builtins.baseNameOf firstWord);

  binds = {
    "Mod+Space".spawn-sh = "${lib.getExe perSystem.self.noctalia} ipc call launcher toggle";
    "Mod+L".spawn-sh = "${lib.getExe perSystem.self.noctalia} ipc call lockScreen lock";
    "Mod+Return".spawn-sh = "alacritty";
    "Mod+Shift+B".spawn = [ (lib.getExe pkgs.firefox) ];
    "Mod+W".close-window = _: { };

    # Window management
    "Mod+F".switch-preset-column-width = _: { };
    "Mod+Shift+Slash".spawn-sh = lib.getExe perSystem.self."hotkey-cheatsheet";
    "Mod+Left".focus-column-left = _: { };
    "Mod+Right".focus-column-right = _: { };
    "Mod+Shift+Left".move-column-left = _: { };
    "Mod+Shift+Right".move-column-right = _: { };
    "Mod+Up".focus-window-or-workspace-up = _: { };
    "Mod+Down".focus-window-or-workspace-down = _: { };
    "Mod+Shift+Up".move-window-up-or-to-workspace-up = _: { };
    "Mod+Shift+Down".move-window-down-or-to-workspace-down = _: { };
    "Mod+C".center-column = _: { };
    "Mod+O".toggle-overview = _: { };

    # Monitor focus
    "Mod+Ctrl+Left".focus-monitor-left = _: { };
    "Mod+Ctrl+Right".focus-monitor-right = _: { };

    # Move window to monitor
    "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = _: { };
    "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = _: { };
  }
  ;

  # Exclude the cheatsheet bind to avoid self-reference in the shortcut list
  displayBinds = builtins.removeAttrs binds [ "Mod+Shift+Slash" ];

  # Extract structured shortcut data from binds at build time
  # Assumption: each bind entry has exactly one action key
  shortcutEntries = lib.mapAttrsToList (
    keyCombo: actionSet:
    let
      actionName = builtins.head (builtins.attrNames actionSet);
      actionValue = actionSet.${actionName};
    in
    {
      key = keyCombo;
      label =
        if actionName == "spawn-sh" || actionName == "spawn" then
          spawnLabel actionValue
        else
          titleCase actionName;
      command =
        if builtins.isString actionValue then
          actionValue
        else if builtins.isList actionValue then
          builtins.toString (builtins.head actionValue)
        else
          "${pkgs.niri}/bin/niri msg action ${actionName}";
    }
  ) displayBinds;

  entriesFile = pkgs.writeText "hotkey-entries" (
    builtins.concatStringsSep "\n" (map (e: "${e.key} — ${e.label}") shortcutEntries)
  );

  caseBranches = builtins.concatStringsSep "\n" (
    map (e: "  \"${e.key} — ${e.label}\") ${e.command} ;;") shortcutEntries
  );
in
{
  inherit binds;

  hotkeyCheatsheet = pkgs.writeShellScriptBin "hotkey-cheatsheet" ''
    choice=$(${lib.getExe pkgs.fuzzel} --dmenu < ${entriesFile})
    [ -z "$choice" ] && exit 0
    case "$choice" in
    ${caseBranches}
    esac
  '';
}
