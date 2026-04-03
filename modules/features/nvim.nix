{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.nvim =
    {
      pkgs,
      libs,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.wl-clipboard
        self.packages.${pkgs.stdenv.system}.myNvim
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNvim =
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

                  mini.bufremove.enable = true;
                  mini.animate.enable = true;

                  ui.noice.enable = true;

                  notify.nvim-notify.enable = true;

                  visuals.indent-blankline.enable = true;

                  keymaps = [
                    # --- General / Better Defaults ---
                    {
                      key = "jk";
                      mode = "i";
                      action = "<Esc>";
                      desc = "Exit insert mode";
                    }
                    {
                      key = "<C-s>";
                      mode = "n";
                      action = "<cmd>w<CR>";
                      desc = "Save file";
                    }
                    {
                      key = "<C-s>";
                      mode = "i";
                      action = "<cmd>w<CR>";
                      desc = "Save file";
                    }
                    {
                      key = "<C-s>";
                      mode = "v";
                      action = "<cmd>w<CR>";
                      desc = "Save file";
                    }
                    {
                      key = "<Esc>";
                      mode = "n";
                      action = "<cmd>noh<CR>";
                      desc = "Clear search highlight";
                    }
                    {
                      key = "<leader>qq";
                      mode = "n";
                      action = "<cmd>qa<CR>";
                      desc = "Quit all";
                    }
                    {
                      key = "j";
                      mode = "n";
                      action = "gj";
                      desc = "Move down (wrapped lines)";
                    }
                    {
                      key = "k";
                      mode = "n";
                      action = "gk";
                      desc = "Move up (wrapped lines)";
                    }
                    {
                      key = "<C-Up>";
                      mode = "n";
                      action = "<cmd>resize +2<CR>";
                      desc = "Increase window height";
                    }
                    {
                      key = "<C-Down>";
                      mode = "n";
                      action = "<cmd>resize -2<CR>";
                      desc = "Decrease window height";
                    }
                    {
                      key = "<C-Left>";
                      mode = "n";
                      action = "<cmd>vertical resize -2<CR>";
                      desc = "Decrease window width";
                    }
                    {
                      key = "<C-Right>";
                      mode = "n";
                      action = "<cmd>vertical resize +2<CR>";
                      desc = "Increase window width";
                    }
                    {
                      key = "<A-j>";
                      mode = "n";
                      action = "<cmd>m .+1<CR>==";
                      desc = "Move line down";
                    }
                    {
                      key = "<A-j>";
                      mode = "i";
                      action = "<Esc><cmd>m .+1<CR>==gi";
                      desc = "Move line down";
                    }
                    {
                      key = "<A-j>";
                      mode = "v";
                      action = ":m '>+1<CR>gv=gv";
                      desc = "Move lines down";
                    }
                    {
                      key = "<A-k>";
                      mode = "n";
                      action = "<cmd>m .-2<CR>==";
                      desc = "Move line up";
                    }
                    {
                      key = "<A-k>";
                      mode = "i";
                      action = "<Esc><cmd>m .-2<CR>==gi";
                      desc = "Move line up";
                    }
                    {
                      key = "<A-k>";
                      mode = "v";
                      action = ":m '<-2<CR>gv=gv";
                      desc = "Move lines up";
                    }

                    # --- Windows ---
                    {
                      key = "<leader>wh";
                      mode = "n";
                      action = "<C-w>h";
                      desc = "Go to left window";
                    }
                    {
                      key = "<leader>wj";
                      mode = "n";
                      action = "<C-w>j";
                      desc = "Go to lower window";
                    }
                    {
                      key = "<leader>wk";
                      mode = "n";
                      action = "<C-w>k";
                      desc = "Go to upper window";
                    }
                    {
                      key = "<leader>wl";
                      mode = "n";
                      action = "<C-w>l";
                      desc = "Go to right window";
                    }
                    {
                      key = "<leader>wd";
                      mode = "n";
                      action = "<C-w>c";
                      desc = "Delete window";
                    }
                    {
                      key = "<leader>ws";
                      mode = "n";
                      action = "<C-w>s";
                      desc = "Split window below";
                    }
                    {
                      key = "<leader>wv";
                      mode = "n";
                      action = "<C-w>v";
                      desc = "Split window right";
                    }

                    # --- Buffers ---
                    {
                      key = "<S-h>";
                      mode = "n";
                      action = "<cmd>BufferLineCyclePrev<CR>";
                      desc = "Previous buffer";
                    }
                    {
                      key = "<S-l>";
                      mode = "n";
                      action = "<cmd>BufferLineCycleNext<CR>";
                      desc = "Next buffer";
                    }
                    {
                      key = "<leader>bd";
                      mode = "n";
                      action = "function() require('mini.bufremove').delete(0, false) end";
                      desc = "Delete buffer";
                      lua = true;
                    }
                    {
                      key = "<leader>bo";
                      mode = "n";
                      action = "<cmd>BufferLineCloseOthers<CR>";
                      desc = "Close other buffers";
                    }
                    {
                      key = "<leader>bp";
                      mode = "n";
                      action = "<cmd>BufferLineTogglePin<CR>";
                      desc = "Toggle pin";
                    }
                    {
                      key = "<leader>bb";
                      mode = "n";
                      action = "<cmd>Telescope buffers<CR>";
                      desc = "Switch buffer";
                    }

                    # --- Find/Search (Telescope) ---
                    {
                      key = "<leader>ff";
                      mode = "n";
                      action = "<cmd>Telescope find_files<CR>";
                      desc = "Find files";
                    }
                    {
                      key = "<leader>fg";
                      mode = "n";
                      action = "<cmd>Telescope live_grep<CR>";
                      desc = "Grep files";
                    }
                    {
                      key = "<leader>fb";
                      mode = "n";
                      action = "<cmd>Telescope buffers<CR>";
                      desc = "Find buffers";
                    }
                    {
                      key = "<leader>fr";
                      mode = "n";
                      action = "<cmd>Telescope oldfiles<CR>";
                      desc = "Recent files";
                    }
                    {
                      key = "<leader>fc";
                      mode = "n";
                      action = "<cmd>Telescope find_files cwd=~/.config/nvim<CR>";
                      desc = "Find config file";
                    }
                    {
                      key = "<leader>ss";
                      mode = "n";
                      action = "<cmd>Telescope grep_string<CR>";
                      desc = "Search word under cursor";
                    }
                    {
                      key = "<leader>sg";
                      mode = "n";
                      action = "<cmd>Telescope live_grep<CR>";
                      desc = "Search by grep";
                    }
                    {
                      key = "<leader>sh";
                      mode = "n";
                      action = "<cmd>Telescope help_tags<CR>";
                      desc = "Search help";
                    }
                    {
                      key = "<leader>sk";
                      mode = "n";
                      action = "<cmd>Telescope keymaps<CR>";
                      desc = "Search keymaps";
                    }
                    {
                      key = "<leader>sm";
                      mode = "n";
                      action = "<cmd>Telescope marks<CR>";
                      desc = "Search marks";
                    }
                    {
                      key = "<leader>sr";
                      mode = "n";
                      action = "<cmd>Telescope resume<CR>";
                      desc = "Resume last search";
                    }

                    # --- LSP / Code ---
                    {
                      key = "gd";
                      mode = "n";
                      action = "<cmd>Telescope lsp_definitions<CR>";
                      desc = "Go to definition";
                    }
                    {
                      key = "gr";
                      mode = "n";
                      action = "<cmd>Telescope lsp_references<CR>";
                      desc = "Go to references";
                    }
                    {
                      key = "gI";
                      mode = "n";
                      action = "<cmd>Telescope lsp_implementations<CR>";
                      desc = "Go to implementation";
                    }
                    {
                      key = "gy";
                      mode = "n";
                      action = "<cmd>Telescope lsp_type_definitions<CR>";
                      desc = "Go to type definition";
                    }
                    {
                      key = "K";
                      mode = "n";
                      action = "vim.lsp.buf.hover";
                      desc = "Hover docs";
                      lua = true;
                    }
                    {
                      key = "gK";
                      mode = "n";
                      action = "vim.lsp.buf.signature_help";
                      desc = "Signature help";
                      lua = true;
                    }
                    {
                      key = "<leader>ca";
                      mode = "n";
                      action = "vim.lsp.buf.code_action";
                      desc = "Code action";
                      lua = true;
                    }
                    {
                      key = "<leader>ca";
                      mode = "v";
                      action = "vim.lsp.buf.code_action";
                      desc = "Code action";
                      lua = true;
                    }
                    {
                      key = "<leader>cr";
                      mode = "n";
                      action = "vim.lsp.buf.rename";
                      desc = "Rename symbol";
                      lua = true;
                    }
                    {
                      key = "<leader>cf";
                      mode = "n";
                      action = "vim.lsp.buf.format";
                      desc = "Format document";
                      lua = true;
                    }
                    {
                      key = "<leader>cd";
                      mode = "n";
                      action = "vim.diagnostic.open_float";
                      desc = "Line diagnostics";
                      lua = true;
                    }
                    {
                      key = "]d";
                      mode = "n";
                      action = "vim.diagnostic.goto_next";
                      desc = "Next diagnostic";
                      lua = true;
                    }
                    {
                      key = "[d";
                      mode = "n";
                      action = "vim.diagnostic.goto_prev";
                      desc = "Previous diagnostic";
                      lua = true;
                    }

                    # --- Diagnostics (Trouble) ---
                    {
                      key = "<leader>xx";
                      mode = "n";
                      action = "<cmd>Trouble diagnostics toggle<CR>";
                      desc = "Document diagnostics";
                    }
                    {
                      key = "<leader>xX";
                      mode = "n";
                      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
                      desc = "Buffer diagnostics";
                    }
                    {
                      key = "<leader>xL";
                      mode = "n";
                      action = "<cmd>Trouble loclist toggle<CR>";
                      desc = "Location list";
                    }
                    {
                      key = "<leader>xQ";
                      mode = "n";
                      action = "<cmd>Trouble qflist toggle<CR>";
                      desc = "Quickfix list";
                    }

                    # --- Debug (DAP) ---
                    {
                      key = "<leader>db";
                      mode = "n";
                      action = "require('dap').toggle_breakpoint";
                      desc = "Toggle breakpoint";
                      lua = true;
                    }
                    {
                      key = "<leader>dc";
                      mode = "n";
                      action = "require('dap').continue";
                      desc = "Continue";
                      lua = true;
                    }
                    {
                      key = "<leader>di";
                      mode = "n";
                      action = "require('dap').step_into";
                      desc = "Step into";
                      lua = true;
                    }
                    {
                      key = "<leader>do";
                      mode = "n";
                      action = "require('dap').step_over";
                      desc = "Step over";
                      lua = true;
                    }
                    {
                      key = "<leader>dO";
                      mode = "n";
                      action = "require('dap').step_out";
                      desc = "Step out";
                      lua = true;
                    }
                    {
                      key = "<leader>dt";
                      mode = "n";
                      action = "require('dap').terminate";
                      desc = "Terminate";
                      lua = true;
                    }
                    {
                      key = "<leader>du";
                      mode = "n";
                      action = "require('dapui').toggle";
                      desc = "Toggle DAP UI";
                      lua = true;
                    }

                    # --- File Explorer ---
                    {
                      key = "<leader>e";
                      mode = "n";
                      action = "<cmd>Neotree toggle<CR>";
                      desc = "Toggle file explorer";
                    }
                    {
                      key = "<leader>E";
                      mode = "n";
                      action = "<cmd>Neotree reveal<CR>";
                      desc = "Reveal file in explorer";
                    }
                    {
                      key = "<leader>ge";
                      mode = "n";
                      action = "<cmd>Neotree git_status<CR>";
                      desc = "Git explorer";
                    }
                    {
                      key = "<leader>be";
                      mode = "n";
                      action = "<cmd>Neotree buffers<CR>";
                      desc = "Buffer explorer";
                    }

                    # --- Git ---
                    {
                      key = "<leader>gg";
                      mode = "n";
                      action = "function() require('toggleterm.terminal').Terminal:new({cmd='lazygit', hidden=true, direction='float'}):toggle() end";
                      desc = "Lazygit";
                      lua = true;
                    }
                    {
                      key = "<leader>ghs";
                      mode = "n";
                      action = "require('gitsigns').stage_hunk";
                      desc = "Stage hunk";
                      lua = true;
                    }
                    {
                      key = "<leader>ghr";
                      mode = "n";
                      action = "require('gitsigns').reset_hunk";
                      desc = "Reset hunk";
                      lua = true;
                    }
                    {
                      key = "<leader>ghp";
                      mode = "n";
                      action = "require('gitsigns').preview_hunk";
                      desc = "Preview hunk";
                      lua = true;
                    }
                    {
                      key = "<leader>ghb";
                      mode = "n";
                      action = "require('gitsigns').blame_line";
                      desc = "Blame line";
                      lua = true;
                    }
                    {
                      key = "]h";
                      mode = "n";
                      action = "require('gitsigns').next_hunk";
                      desc = "Next hunk";
                      lua = true;
                    }
                    {
                      key = "[h";
                      mode = "n";
                      action = "require('gitsigns').prev_hunk";
                      desc = "Previous hunk";
                      lua = true;
                    }

                    # --- UI Toggles ---
                    {
                      key = "<leader>un";
                      mode = "n";
                      action = "function() vim.o.number = not vim.o.number end";
                      desc = "Toggle line numbers";
                      lua = true;
                    }
                    {
                      key = "<leader>ur";
                      mode = "n";
                      action = "function() vim.o.relativenumber = not vim.o.relativenumber end";
                      desc = "Toggle relative numbers";
                      lua = true;
                    }
                    {
                      key = "<leader>uw";
                      mode = "n";
                      action = "function() vim.o.wrap = not vim.o.wrap end";
                      desc = "Toggle word wrap";
                      lua = true;
                    }
                    {
                      key = "<leader>us";
                      mode = "n";
                      action = "function() vim.o.spell = not vim.o.spell end";
                      desc = "Toggle spell check";
                      lua = true;
                    }
                    {
                      key = "<leader>ud";
                      mode = "n";
                      action = "function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end";
                      desc = "Toggle diagnostics";
                      lua = true;
                    }
                    {
                      key = "<leader>uc";
                      mode = "n";
                      action = "function() vim.o.conceallevel = vim.o.conceallevel == 0 and 2 or 0 end";
                      desc = "Toggle conceal";
                      lua = true;
                    }
                  ];

                  statusline.lualine.enable = true;
                  telescope.enable = true;
                  autocomplete.nvim-cmp.enable = true;

                  spellcheck = {
                    enable = true;
                    programmingWordlist.enable = true;
                  };

                  lsp = {
                    # This must be enabled for the language modules to hook into
                    # the LSP API.
                    enable = true;

                    formatOnSave = false;
                    lspkind.enable = false;
                    lightbulb.enable = true;
                    lspsaga.enable = false;
                    trouble.enable = true;
                    lspSignature.enable = !true; # conflicts with blink in maximal
                    otter-nvim.enable = true;
                    nvim-docs-view.enable = true;
                    harper-ls.enable = true;
                  };

                  debugger = {
                    nvim-dap = {
                      enable = true;
                      ui.enable = true;
                    };
                  };

                  # This section does not include a comprehensive list of available language modules.
                  # To list all available language module options, please visit the nvf manual.
                  languages = {
                    enableFormat = true;
                    enableTreesitter = true;
                    enableExtraDiagnostics = true;

                    # Languages that will be supported in default and maximal configurations.
                    nix.enable = true;
                    markdown.enable = true;
                  };
                };
              }
            )
          ];
        }).neovim;
    };
}
