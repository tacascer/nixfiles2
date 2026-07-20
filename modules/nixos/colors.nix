{ inputs, ... }:
{ lib, ... }:
{
  options.custom.colorScheme = lib.mkOption {
    type = lib.types.attrs;
    default = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
    description = "Base16 color scheme from nix-colors";
  };
}
