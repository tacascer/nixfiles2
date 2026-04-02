{ self, ... }:
{
  flake.nixosModules."1password" =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs._1password = {
        enable = true;
      };

      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "tacascer" ];
      };

      programs.ssh = {
        extraConfig = ''
          Host *
              IdentityAgent ~/.1password/agent.sock
        '';
      };

      environment.sessionVariables = {
        SSH_AUTH_SOCK = "/home/tacascer/.1password/agent.sock";
      };
    };
}
