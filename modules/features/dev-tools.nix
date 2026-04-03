{ inputs, ... }:
{
  flake.nixosModules.dev-tools =
    { pkgs, ... }:
    {
      programs.bash = {
        shellAliases = {
          bazel = "bazelisk";
        };
      };
      programs.nix-ld.enable = true;
      programs.direnv.enable = true;

      environment.systemPackages = [
        pkgs.bazelisk
        pkgs.jq
        pkgs.gh
      ];
    };
}
