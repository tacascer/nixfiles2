{ self, ... }:
{
  flake.nixosModules.sudo =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.custom.sudo;
    in
    {
      options.custom.sudo = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "Username to grant passwordless sudo for nixos-rebuild and nix.";
        };
      };

      config.security.sudo.extraRules = [
        {
          users = [ cfg.username ];
          commands = [
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
}
