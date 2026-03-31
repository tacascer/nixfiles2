{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nvim = {
    pkgs,
    libs,
    ...
  }: {
    environment.systemPackages = [
      pkgs.nixfmt
      pkgs.wl-clipboard
      self.packages.${pkgs.stdenv.system}.myNvim
    ];
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.myNvim =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          (
            {pkgs, ...}: {
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

                  formatOnSave = true;
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
