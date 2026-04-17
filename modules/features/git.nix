{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.git =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myGit
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      unfreePkgs = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
        pkgs = unfreePkgs;
        settings = {
          core.excludesFile = toString (
            pkgs.writeText "global-gitignore" ''
              .omc/
              .worktrees/
            ''
          );
          user = {
            name = "tacascer";
            email = "trandangtrithanh2000@gmail.com";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4F11qhcGezqNnuicjl99tvcXdIeymu0wdPLBivoZEg";
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
