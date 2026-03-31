{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.claude-code = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myClaudeCode
    ];
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.myClaudeCode = inputs.wrapper-modules.wrappers.claude-code.wrap {
      pkgs = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        settings = {
          includeCoAuthoredBy = false;
        };
      };
    };
  };
}
