{
  lib,
  pkgs,
  ohMyOpenAgentSrc,
  ohMyOpenAgentSettings ? { },
  ...
}:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${ohMyOpenAgentSrc}/package.json");
  jsonFormat = pkgs.formats.json { };
  runtimeDependencies = packageMeta.dependencies // (packageMeta.peerDependencies or { });
  pluginConfigFile = jsonFormat.generate "oh-my-openagent.json" ohMyOpenAgentSettings;
  opencodePackageJson = jsonFormat.generate "opencode-package.json" {
    type = packageMeta.type or "module";
    dependencies = runtimeDependencies;
  };
in
{
  programs.opencode = {
    enable = true;
    extraPackages = [ pkgs.bun ];
    commands = "${ohMyOpenAgentSrc}/.opencode/command";
    skills = "${ohMyOpenAgentSrc}/.opencode/skills";
  };

  xdg.configFile = {
    "opencode/oh-my-openagent.json".source = pluginConfigFile;
    "opencode/package.json".source = opencodePackageJson;
    "opencode/plugins/oh-my-openagent.ts".text = ''
      export { default } from ${builtins.toJSON "${ohMyOpenAgentSrc}/src/index.ts"};
    '';
  };
}
