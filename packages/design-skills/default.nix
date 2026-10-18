{ pkgs, inputs, ... }:
let
  inherit (pkgs) lib;
  emilSkills = [
    "animate"
    "animate-expo"
    "animation-performance"
    "animation-vocabulary"
    "apple-design"
    "ask-sonner"
    "break-ui"
    "emil-design-eng"
    "find-animation-opportunities"
    "improve-animations"
    "mobile-native"
    "pick-ui-library"
    "prototype"
    "review-animations"
    "write-swift"
  ];
  explicitOnlySkills = [
    "pick-ui-library"
    "prototype"
    "review-animations"
  ];
  installedName = name: if name == "prototype" then "emil-prototype" else name;
  skillNames = [
    "frontend-design"
    "impeccable"
  ]
  ++ map installedName emilSkills;
  engineVersion = "0.1.15";
  engineTargets = {
    x86_64-linux = {
      target = "linux-x64";
      sha256 = "b4e2ebcb97b2be5e5a0ae71d4a03596c12d3672f19b24cfdd7244e304e679fb7";
    };
    aarch64-linux = {
      target = "linux-arm64";
      sha256 = "bb572a5250359731b3df902279ed4c3a901b149742b36623c2130f15221561e4";
    };
    aarch64-darwin = {
      target = "darwin-arm64";
      sha256 = "c7914209b4490dc81b7ab17c20f1f76415d1f0b8bb5de6f7e86e9aa111d1c1a5";
    };
  };
  engineTarget = engineTargets.${pkgs.stdenv.hostPlatform.system};
  engine = pkgs.stdenvNoCC.mkDerivation {
    pname = "impeccable-engine";
    version = engineVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/pbakaus/impeccable/releases/download/engine-v${engineVersion}/impeccable-${engineTarget.target}";
      inherit (engineTarget) sha256;
    };
    dontUnpack = true;
    nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.stdenv.cc.cc.lib ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/impeccable"
      runHook postInstall
    '';
    meta = {
      description = "Pinned runtime for the Impeccable design skill";
      license = lib.licenses.asl20;
      platforms = builtins.attrNames engineTargets;
    };
  };
in
assert lib.assertMsg (
  lib.trim (builtins.readFile "${inputs.impeccable}/ENGINE_VERSION") == engineVersion
) "Update the Impeccable engine version and release checksums with its skill input";
pkgs.runCommand "design-skills"
  {
    passthru = { inherit skillNames; };
    meta = {
      description = "Anthropic, Emil Kowalski, and Impeccable agent design skills";
      license = [
        lib.licenses.asl20
        lib.licenses.mit
      ];
      platforms = builtins.attrNames engineTargets;
    };
  }
  ''
    mkdir -p "$out/share/agents" "$out/share/claude"
    ln -s ${inputs.anthropic-skills}/skills/frontend-design "$out/share/agents/frontend-design"
    ${lib.concatMapStringsSep "\n" (name: ''
      ln -s ${inputs.emilkowalski-skills}/skills/${name} "$out/share/agents/${installedName name}"
    '') (builtins.filter (name: !(builtins.elem name explicitOnlySkills)) emilSkills)}

    # Translate Claude's explicit-only policy to Codex's native policy metadata.
    ${lib.concatMapStringsSep "\n" (name: ''
      skill="$out/share/agents/${installedName name}"
      cp -R ${inputs.emilkowalski-skills}/skills/${name} "$skill"
      chmod -R u+w "$skill"
      mkdir -p "$skill/agents"
      test ! -e "$skill/agents/openai.yaml"
      printf 'policy:\n  allow_implicit_invocation: false\n' > "$skill/agents/openai.yaml"
    '') explicitOnlySkills}

    # Rename metadata as well as the directory, so discovery cannot shadow Matt's skill.
    substituteInPlace "$out/share/agents/emil-prototype/SKILL.md" \
      --replace-fail 'name: prototype' 'name: emil-prototype'

    for name in ${lib.escapeShellArgs (builtins.filter (name: name != "impeccable") skillNames)}; do
      ln -s "$out/share/agents/$name" "$out/share/claude/$name"
    done

    # Use upstream's complete provider bundles, including references, scripts and agents.
    cp -R ${inputs.impeccable}/.agents/skills/impeccable "$out/share/agents/impeccable"
    cp -R ${inputs.impeccable}/plugin/skills/impeccable "$out/share/claude/impeccable"
    for provider in agents claude; do
      skill="$out/share/$provider/impeccable"
      chmod -R u+w "$skill"
      patchShebangs "$skill/scripts/impeccable"
      mkdir -p "$skill/scripts/bin/${engineTarget.target}"
      ln -s ${engine}/bin/impeccable "$skill/scripts/bin/${engineTarget.target}/impeccable"
    done

    mkdir -p "$out/share/licenses/design-skills"
    cp ${inputs.emilkowalski-skills}/LICENSE "$out/share/licenses/design-skills/emilkowalski"
    cp ${inputs.impeccable}/LICENSE "$out/share/licenses/design-skills/impeccable"
    cp ${inputs.impeccable}/NOTICE.md "$out/share/licenses/design-skills/impeccable-NOTICE.md"
  ''
