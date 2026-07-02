{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "tokyonight_storm";
      editor = {
        auto-format = true;
        bufferline = "multiple";
        color-modes = true;
        cursorline = true;
        line-number = "relative";
        true-color = true;
        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };
        soft-wrap.enable = true;
        whitespace.render = "all";
      };
    };

    ignores = [
      ".direnv/"
      ".git/"
      ".worktrees/"
      "bazel-bin/"
      "bazel-out/"
      "bazel-testlogs/"
      "bazel-bazel-repo/"
      "node_modules/"
      "target/"
    ];

    extraPackages = with pkgs; [
      bash-language-server
      fourmolu
      go
      gofumpt
      gopls
      haskell-language-server
      kotlin-language-server
      ktlint
      lemminx
      markdownlint-cli
      marksman
      nil
      nixfmt
      prettier
      rust-analyzer
      rustfmt
      shellcheck
      shfmt
      sqls
      starpls
      taplo
      typescript
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
      yamlfmt
      zig
      zls
    ];

    languages = {
      language-server = {
        nil.command = "nil";
        marksman.command = "marksman";
        typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
        kotlin-language-server.command = "kotlin-language-server";
        rust-analyzer = {
          command = "rust-analyzer";
          config.files.excludeDirs = [
            ".direnv"
            ".git"
            ".worktrees"
            "bazel-bin"
            "bazel-out"
            "bazel-testlogs"
            "bazel-bazel-repo"
            "node_modules"
            "target"
          ];
        };
        zls.command = "zls";
        gopls.command = "gopls";
        haskell-language-server.command = "haskell-language-server-wrapper";
        vscode-html-language-server = {
          command = "vscode-html-language-server";
          args = [ "--stdio" ];
        };
        vscode-css-language-server = {
          command = "vscode-css-language-server";
          args = [ "--stdio" ];
        };
        sqls.command = "sqls";
        bash-language-server = {
          command = "bash-language-server";
          args = [ "start" ];
        };
        vscode-json-language-server = {
          command = "vscode-json-language-server";
          args = [ "--stdio" ];
        };
        yaml-language-server = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
        };
        taplo.command = "taplo";
        lemminx.command = "lemminx";
        starpls.command = "starpls";
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
          language-servers = [ "nil" ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "markdown"
            ];
          };
          language-servers = [ "marksman" ];
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "tsx";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "babel"
            ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "jsx";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "babel"
            ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "kotlin";
          auto-format = true;
          language-servers = [ "kotlin-language-server" ];
        }
        {
          name = "rust";
          auto-format = true;
          formatter.command = "rustfmt";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "zig";
          auto-format = true;
          language-servers = [ "zls" ];
        }
        {
          name = "go";
          auto-format = true;
          formatter.command = "gofumpt";
          language-servers = [ "gopls" ];
        }
        {
          name = "haskell";
          auto-format = true;
          formatter.command = "fourmolu";
          language-servers = [ "haskell-language-server" ];
        }
        {
          name = "html";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "html"
            ];
          };
          language-servers = [ "vscode-html-language-server" ];
        }
        {
          name = "css";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "css"
            ];
          };
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "scss";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "scss"
            ];
          };
          language-servers = [ "vscode-css-language-server" ];
        }
        {
          name = "sql";
          auto-format = true;
          language-servers = [ "sqls" ];
        }
        {
          name = "bash";
          auto-format = true;
          formatter.command = "shfmt";
          language-servers = [ "bash-language-server" ];
        }
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "json"
            ];
          };
          language-servers = [ "vscode-json-language-server" ];
        }
        {
          name = "yaml";
          auto-format = true;
          formatter.command = "yamlfmt";
          language-servers = [ "yaml-language-server" ];
        }
        {
          name = "toml";
          auto-format = true;
          formatter = {
            command = "taplo";
            args = [
              "format"
              "-"
            ];
          };
          language-servers = [ "taplo" ];
        }
        {
          name = "xml";
          auto-format = true;
          language-servers = [ "lemminx" ];
        }
        {
          name = "starlark";
          scope = "source.starlark";
          injection-regex = "^(starlark|bzl)$";
          file-types = [
            "bzl"
            "star"
            { glob = "BUILD"; }
            { glob = "BUILD.bazel"; }
            { glob = "WORKSPACE"; }
            { glob = "WORKSPACE.bazel"; }
            { glob = "MODULE.bazel"; }
          ];
          roots = [
            "MODULE.bazel"
            "WORKSPACE"
            "WORKSPACE.bazel"
            ".git"
          ];
          auto-format = true;
          language-servers = [ "starpls" ];
        }
      ];
    };
  };
}
