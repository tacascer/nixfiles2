{ self, inputs, ... }: {

  perSystem = { pkgs, lib, self', ... }: {
    packages.myHotkeyCheatsheet = pkgs.writeShellScriptBin "hotkey-cheatsheet" ''
      choice=$(cat <<'ENTRIES' | ${lib.getExe pkgs.fuzzel} --dmenu --prompt="Hotkeys: "
      Mod+W — Close Window
      Mod+F — Maximize
      Mod+C — Center Column
      Mod+O — Toggle Overview
      Mod+Left — Focus Left
      Mod+Right — Focus Right
      Mod+Up — Focus Up
      Mod+Down — Focus Down
      Mod+Shift+Left — Move Left
      Mod+Shift+Right — Move Right
      Mod+Shift+Up — Move Up
      Mod+Shift+Down — Move Down
      Mod+Ctrl+Left — Focus Monitor Left
      Mod+Ctrl+Right — Focus Monitor Right
      Mod+Shift+Ctrl+Left — Move to Monitor Left
      Mod+Shift+Ctrl+Right — Move to Monitor Right
      Mod+Space — Launcher
      Mod+Return — Terminal
      ENTRIES
      )

      case "$choice" in
        "Mod+W — Close Window") niri msg action close-window ;;
        "Mod+F — Maximize") niri msg action maximize-column ;;
        "Mod+C — Center Column") niri msg action center-column ;;
        "Mod+O — Toggle Overview") niri msg action toggle-overview ;;
        "Mod+Left — Focus Left") niri msg action focus-column-left ;;
        "Mod+Right — Focus Right") niri msg action focus-column-right ;;
        "Mod+Up — Focus Up") niri msg action focus-window-or-workspace-up ;;
        "Mod+Down — Focus Down") niri msg action focus-window-or-workspace-down ;;
        "Mod+Shift+Left — Move Left") niri msg action move-column-left ;;
        "Mod+Shift+Right — Move Right") niri msg action move-column-right ;;
        "Mod+Shift+Up — Move Up") niri msg action move-window-up-or-to-workspace-up ;;
        "Mod+Shift+Down — Move Down") niri msg action move-window-down-or-to-workspace-down ;;
        "Mod+Ctrl+Left — Focus Monitor Left") niri msg action focus-monitor-left ;;
        "Mod+Ctrl+Right — Focus Monitor Right") niri msg action focus-monitor-right ;;
        "Mod+Shift+Ctrl+Left — Move to Monitor Left") niri msg action move-column-to-monitor-left ;;
        "Mod+Shift+Ctrl+Right — Move to Monitor Right") niri msg action move-column-to-monitor-right ;;
        "Mod+Space — Launcher") ${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle ;;
        "Mod+Return — Terminal") ${lib.getExe self'.packages.myAlacritty} ;;
      esac
    '';
  };
}
