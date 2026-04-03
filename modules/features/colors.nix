{ inputs, ... }:
{
  flake.nixosModules.colors =
    { lib, ... }:
    {
      options.custom.colorScheme = lib.mkOption {
        type = lib.types.attrs;
        default = inputs.nix-colors.colorSchemes.tokyo-night-terminal-storm;
        description = "Base16 color scheme from nix-colors";
      };
    };
}
