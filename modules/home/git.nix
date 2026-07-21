{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    ignores = [
      ".omc/"
      ".worktrees/"
      ".sisyphus/"
      ".pi-subagents/"
    ];

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4F11qhcGezqNnuicjl99tvcXdIeymu0wdPLBivoZEg";
      format = "ssh";
      signer = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
    };

    settings = {
      commit.gpgSign = true;
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      init.defaultBranch = "main";
      pull.rebase = true;
      user = {
        name = "tacascer";
        email = "trandangtrithanh2000@gmail.com";
      };
    };
  };
}
