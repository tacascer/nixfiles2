{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.git = {
    pkgs,
    lib,
    ...
  }: {
    programs.git = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myGit;
    };
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    unfreePkgs = import inputs.nixpkgs {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {
    packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
      pkgs = unfreePkgs;
      settings = {
        user = {
          name = "tacascer";
          email = "trandangtrithanh2000@gmail.com";
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZeXSfiPpjH/9Jik03i2itMcpW/If0j5spJbzq9jWXb";
        };
        commit.gpgsign = true;
        gpg.format = "ssh";
        "gpg \"ssh\"" = {
          program = "${unfreePkgs._1password-gui}/share/1password/op-ssh-sign";
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
