{ ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        decorations = "None";
        padding = {
          x = 8;
          y = 8;
        };
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
