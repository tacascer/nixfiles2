{ ... }:
{
  flake.nixosModules.limine =
    { config, ... }:
    let
      palette = config.custom.colorScheme.palette;
    in
    {
      # WARNING: nixpkgs limine module has known open issues — verify these are resolved before enabling:
      # - https://github.com/NixOS/nixpkgs/issues/493017 (sporadic bootloader installation failures)
      # - https://github.com/nixos/nixpkgs/issues/494822 (EFI registration error handling)
      # - https://github.com/NixOS/nixpkgs/issues/443031 (latest generation not always default)

      boot.loader.limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;

        # Windows 11 chainloading — verify path matches your ESP layout before enabling.
        # Current systemd-boot config uses efiDeviceHandle = "HD1b" (separate ESP).
        # If Windows EFI is on a different partition, use guid(...):/EFI/Microsoft/Boot/bootmgfw.efi
        # TODO: Consider host-conditional Windows entry when enabling (see Option B in plan).
        extraEntries = ''
          / Windows 11
              protocol: efi
              path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        style = {
          wallpapers = [ ];
          backdrop = palette.base00;
          graphicalTerminal = {
            foreground = palette.base05;
            background = "FF${palette.base00}";
            # base16 standard palette mapping:
            # black, red, green, yellow, blue, magenta, cyan, white
            palette = "${palette.base00};${palette.base08};${palette.base0B};${palette.base0A};${palette.base0D};${palette.base0E};${palette.base0C};${palette.base04}";
            brightPalette = "${palette.base03};${palette.base08};${palette.base0B};${palette.base0A};${palette.base0D};${palette.base0E};${palette.base0C};${palette.base05}";
          };
        };
      };
    };
}
