{ pkgs, inputs, ... }:
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        config.vim = {
          theme = {
            enable = true;
            name = "tokyonight";
            style = "storm";
          };
          viAlias = true;
          vimAlias = true;

          # vim.opts and vim.options are aliased
          opts = {
            expandtab = true;
            tabstop = 2;
            shiftwidth = 2;
            softtabstop = 2;
            clipboard = "unnamedplus";
          };

          globals = {
            mapleader = " ";
            maplocalleader = " ";
          };

          binds.whichKey = {
            enable = true;
            register = {
              "<leader>b" = "+Buffer";
              "<leader>c" = "+Code";
              "<leader>d" = "+Debug";
              "<leader>f" = "+Find";
              "<leader>g" = "+Git";
              "<leader>gh" = "+Hunks";
              "<leader>q" = "+Quit/Session";
              "<leader>s" = "+Search";
              "<leader>u" = "+UI";
              "<leader>w" = "+Windows";
              "<leader>x" = "+Diagnostics";
              "]" = "+Next";
              "[" = "+Previous";
            };
          };

          filetree.neo-tree = {
            enable = true;
            setupOpts.window.mappings = {
              h = "close_node";
              l = "open";
            };
          };

          tabline.nvimBufferline.enable = true;

          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
          };

          git.gitsigns.enable = true;

          utility.motion.flash-nvim.enable = true;

          navigation.harpoon = {
            enable = true;
            mappings = {
              markFile = "<leader>fa";
              listMarks = "<leader>fh";
              file1 = "<leader>1";
              file2 = "<leader>2";
              file3 = "<leader>3";
              file4 = "<leader>4";
            };
          };

          mini.bufremove.enable = true;
          mini.animate.enable = true;

          ui.noice.enable = true;
          ui.breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };

          notify.nvim-notify.enable = true;

          visuals.indent-blankline.enable = true;

          extraLuaFiles = [
            (pkgs.writeText "highlight-yank.lua" ''
              vim.api.nvim_create_autocmd("TextYankPost", {
                callback = function()
                  vim.highlight.on_yank()
                end,
              })
            '')
          ];
        }).neovim
