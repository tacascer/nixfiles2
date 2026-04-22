{ pkgs, inputs, ... }:
inputs.wrapper-modules.wrappers.fastfetch.wrap {
  inherit pkgs;
  settings = {
    display = {
      size = {
        maxPrefix = "MB";
        ndigits = 0;
        spaceBeforeUnit = "never";
      };
      freq = {
        ndigits = 3;
        spaceBeforeUnit = "never";
      };
    };
    modules = [
      "title"
      "separator"
      "os"
      "host"
      {
        type = "kernel";
        format = "{release}";
      }
      "uptime"
      {
        type = "packages";
        combined = true;
      }
      "shell"
      {
        type = "display";
        compactType = "original";
        key = "Resolution";
      }
      "de"
      "wm"
      "wmtheme"
      "theme"
      "icons"
      "terminal"
      {
        type = "terminalfont";
        format = "{/name}{-}{/}{name}{?size} {size}{?}";
      }
      "cpu"
      {
        type = "gpu";
        key = "GPU";
        format = "{name}";
      }
      {
        type = "memory";
        format = "{used} / {total}";
      }
      "break"
      "colors"
    ];
  };
}
