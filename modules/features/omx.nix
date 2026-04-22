{ self, ... }:
{
  flake.nixosModules.omx =
    {
      pkgs,
      lib,
      ...
    }:
    let
      version = "0.14.2";
      packageLock = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Yeachan-Heo/oh-my-codex/3f4f978f2a1ea950e4ae05e12f687e3f81d3ea39/package-lock.json";
        hash = "sha256-bTYHvVk5jKmfXCfcXIQLd6dxx4s2mmrXd2ToBpB07tM=";
      };

      omx = pkgs.buildNpmPackage {
        pname = "oh-my-codex";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/oh-my-codex/-/oh-my-codex-${version}.tgz";
          hash = "sha512-m0cFb0G1O9gU3/Fs2W/KHYbJ1zR/lTyEMWYQsyY9zlXW0MpqN6xzX1UNl0IIwy1ZcA1b/jBdMXVSgl8R2PmlkQ==";
        };

        npmDepsHash = "sha256-gGlxQLwp0NBsc/SBUEwJJYPMUKre+txgG8SCIBK7NcA=";
        npmFlags = [ "--ignore-scripts" ];
        dontNpmBuild = true;
        postPatch = ''
          cp ${packageLock} package-lock.json
        '';
      };
    in
    {
      environment.systemPackages = [ omx ];
    };

  perSystem =
    { pkgs, lib, ... }:
    let
      version = "0.14.2";
      packageLock = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Yeachan-Heo/oh-my-codex/3f4f978f2a1ea950e4ae05e12f687e3f81d3ea39/package-lock.json";
        hash = "sha256-bTYHvVk5jKmfXCfcXIQLd6dxx4s2mmrXd2ToBpB07tM=";
      };
    in
    {
      packages.myOmx = pkgs.buildNpmPackage {
        pname = "oh-my-codex";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/oh-my-codex/-/oh-my-codex-${version}.tgz";
          hash = "sha512-m0cFb0G1O9gU3/Fs2W/KHYbJ1zR/lTyEMWYQsyY9zlXW0MpqN6xzX1UNl0IIwy1ZcA1b/jBdMXVSgl8R2PmlkQ==";
        };

        npmDepsHash = "sha256-gGlxQLwp0NBsc/SBUEwJJYPMUKre+txgG8SCIBK7NcA=";
        npmFlags = [ "--ignore-scripts" ];
        dontNpmBuild = true;
        postPatch = ''
          cp ${packageLock} package-lock.json
        '';
      };
    };
}
