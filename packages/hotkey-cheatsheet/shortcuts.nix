{
  pkgs,
  lib,
  packages,
  ...
}:
let
  bindings = [
    {
      key = "Mod+Space";
      label = "Noctalia Shell";
      action = "spawn";
      args = [
        (lib.getExe packages.noctalia)
        "ipc"
        "call"
        "launcher"
        "toggle"
      ];
    }
    {
      key = "Mod+L";
      label = "Noctalia Shell";
      action = "spawn";
      args = [
        (lib.getExe packages.noctalia)
        "ipc"
        "call"
        "lockScreen"
        "lock"
      ];
    }
    {
      key = "Mod+Return";
      label = "Alacritty";
      action = "spawn";
      args = [ "alacritty" ];
    }
    {
      key = "Mod+Shift+B";
      label = "Firefox";
      action = "spawn";
      args = [ (lib.getExe pkgs.firefox) ];
    }
    {
      key = "Mod+W";
      label = "Close Window";
      action = "close-window";
    }

    # Window management
    {
      key = "Mod+F";
      label = "Switch Preset Column Width";
      action = "switch-preset-column-width";
    }
    {
      key = "Mod+Shift+Slash";
      label = "Hotkey Cheatsheet";
      action = "spawn";
      args = [ (lib.getExe packages."hotkey-cheatsheet") ];
      showInCheatsheet = false;
    }
    {
      key = "Mod+Left";
      label = "Focus Column Left";
      action = "focus-column-left";
    }
    {
      key = "Mod+Right";
      label = "Focus Column Right";
      action = "focus-column-right";
    }
    {
      key = "Mod+Shift+Left";
      label = "Move Column Left";
      action = "move-column-left";
    }
    {
      key = "Mod+Shift+Right";
      label = "Move Column Right";
      action = "move-column-right";
    }
    {
      key = "Mod+Up";
      label = "Focus Window Or Workspace Up";
      action = "focus-window-or-workspace-up";
    }
    {
      key = "Mod+Down";
      label = "Focus Window Or Workspace Down";
      action = "focus-window-or-workspace-down";
    }
    {
      key = "Mod+Shift+Up";
      label = "Move Window Up Or To Workspace Up";
      action = "move-window-up-or-to-workspace-up";
    }
    {
      key = "Mod+Shift+Down";
      label = "Move Window Down Or To Workspace Down";
      action = "move-window-down-or-to-workspace-down";
    }
    {
      key = "Mod+C";
      label = "Center Column";
      action = "center-column";
    }
    {
      key = "Mod+O";
      label = "Toggle Overview";
      action = "toggle-overview";
    }

    # Monitor focus
    {
      key = "Mod+Ctrl+Left";
      label = "Focus Monitor Left";
      action = "focus-monitor-left";
    }
    {
      key = "Mod+Ctrl+Right";
      label = "Focus Monitor Right";
      action = "focus-monitor-right";
    }

    # Move window to monitor
    {
      key = "Mod+Shift+Ctrl+Left";
      label = "Move Column To Monitor Left";
      action = "move-column-to-monitor-left";
    }
    {
      key = "Mod+Shift+Ctrl+Right";
      label = "Move Column To Monitor Right";
      action = "move-column-to-monitor-right";
    }
  ];

  bindsFor =
    actions:
    lib.listToAttrs (
      map (binding: {
        name = binding.key;
        value.action =
          if binding ? args then actions.${binding.action} binding.args else actions.${binding.action};
      }) bindings
    );

  displayBindings = builtins.filter (binding: binding.showInCheatsheet or true) bindings;

  entriesFile = pkgs.writeText "hotkey-entries" (
    builtins.concatStringsSep "\n" (map (binding: "${binding.key} — ${binding.label}") displayBindings)
  );

  commandFor =
    binding:
    if binding ? args then
      lib.escapeShellArgs binding.args
    else
      "${lib.getExe pkgs.niri} msg action ${binding.action}";

  caseBranches = builtins.concatStringsSep "\n" (
    map (binding: ''"${binding.key} — ${binding.label}") ${commandFor binding} ;;'') displayBindings
  );
in
{
  inherit bindsFor;

  hotkeyCheatsheet = pkgs.writeShellScriptBin "hotkey-cheatsheet" ''
    choice=$(${lib.getExe pkgs.fuzzel} --dmenu < ${entriesFile})
    [ -z "$choice" ] && exit 0
    case "$choice" in
    ${caseBranches}
    esac
  '';
}
