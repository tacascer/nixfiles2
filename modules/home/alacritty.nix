{ lib, ... }:
{
  programs.alacritty = {
    enable = true;
    theme = lib.mkDefault "gruvbox_dark";

    settings = {
      window = {
        decorations = "None";
        padding = {
          x = 8;
          y = 8;
        };
      };

      font = {
        normal.family = lib.mkDefault "Hack Nerd Font";
        size = 12;
      };

      hints.enabled = [
        {
          command = "xdg-open";
          hyperlinks = true;
          post_processing = true;
          persist = false;
          regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\s{-}\\^⟨⟩`]+";
          binding = {
            key = "U";
            mods = "Control|Shift";
          };
          mouse = {
            enabled = true;
            mods = "Shift";
          };
        }
      ];
    };
  };
}
