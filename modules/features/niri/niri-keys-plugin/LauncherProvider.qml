import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI

Item {
  id: root

  property string name: "Niri Shortcuts"
  property var launcher: null
  property bool handleSearch: true
  property string supportedLayouts: "list"
  property string iconMode: Settings.data.appLauncher.iconMode
  property var pluginApi: null

  property var shortcuts: []

  function init() {
    loadShortcuts();
    Logger.i("NiriKeysProvider", "Initialized with " + shortcuts.length + " shortcuts");
  }

  function loadShortcuts() {
    if (!pluginApi || !pluginApi.pluginDir) return;

    var xhr = new XMLHttpRequest();
    xhr.open("GET", "file://" + pluginApi.pluginDir + "/shortcuts.json", false);
    xhr.send();

    if (xhr.status === 200 || xhr.status === 0) {
      try {
        shortcuts = JSON.parse(xhr.responseText);
      } catch (e) {
        Logger.e("NiriKeysProvider", "Failed to parse shortcuts.json: " + e);
        shortcuts = [];
      }
    } else {
      Logger.e("NiriKeysProvider", "Failed to load shortcuts.json: status " + xhr.status);
    }
  }

  function handleCommand(searchText) {
    return searchText.startsWith(">keys");
  }

  function commands() {
    return [
      {
        "name": ">keys",
        "description": "Search niri keyboard shortcuts",
        "icon": iconMode === "tabler" ? "keyboard" : "input-keyboard",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function () {
          launcher.setSearchText(">keys ");
        }
      }
    ];
  }

  function getResults(query) {
    if (!query || shortcuts.length === 0)
      return [];

    var trimmed = query.trim();

    var isCommandMode = trimmed.startsWith(">keys");
    if (isCommandMode) {
      var searchTerm = trimmed.substring(5).trim();
      if (searchTerm.length === 0) {
        return getAllShortcuts();
      }
      trimmed = searchTerm;
    } else {
      if (!trimmed || trimmed.length < 2)
        return [];
    }

    var items = [];
    for (var i = 0; i < shortcuts.length; i++) {
      var s = shortcuts[i];
      items.push({
        "name": s.key + " — " + s.label,
        "searchText": s.key + " " + s.label + " " + (s.action || ""),
        "command": s.command,
        "key": s.key,
        "label": s.label
      });
    }

    var results = FuzzySort.go(trimmed, items, {
      "keys": ["name", "searchText"],
      "limit": 20
    });

    var launcherItems = [];
    for (var j = 0; j < results.length; j++) {
      var entry = results[j].obj;
      var score = results[j].score;

      launcherItems.push({
        "name": entry.key,
        "description": entry.label,
        "icon": iconMode === "tabler" ? "keyboard" : "input-keyboard",
        "isTablerIcon": true,
        "isImage": false,
        "_score": score - 1,
        "provider": root,
        "onActivate": createActivateHandler(entry.command)
      });
    }

    return launcherItems;
  }

  function getAllShortcuts() {
    var launcherItems = [];
    for (var i = 0; i < shortcuts.length; i++) {
      var s = shortcuts[i];
      launcherItems.push({
        "name": s.key,
        "description": s.label,
        "icon": iconMode === "tabler" ? "keyboard" : "input-keyboard",
        "isTablerIcon": true,
        "isImage": false,
        "_score": 0,
        "provider": root,
        "onActivate": createActivateHandler(s.command)
      });
    }
    return launcherItems;
  }

  function createActivateHandler(command) {
    return function () {
      if (launcher)
        launcher.close();

      Qt.callLater(function () {
        var proc = Qt.createQmlObject(
          'import Quickshell; Process { running: true; command: ["sh", "-c", "' + command.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"] }',
          root
        );
      });
    };
  }
}
