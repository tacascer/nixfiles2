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

      environment.systemPackages = with pkgs; [
        bazelisk
        cargo
        jq
        gh
        rustc
        util-linux
      ];
    };
}
