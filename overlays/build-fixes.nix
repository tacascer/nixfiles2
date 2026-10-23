_final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pythonFinal: pythonPrev: {
      diff-cover = pythonPrev.diff-cover.overridePythonAttrs (old: {
        # Pygments now preserves quotes in highlighted text. Retain the tests.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tests/fixtures/{pycodestyle_violations_report{,_external_css},pyflakes_violations_report,pylint_violations_report}.html \
            --replace-fail '&quot;' '"'
        '';
      });
    })
  ];

  # The Sphinx hook reads a scalar. An array selects only its first builder.
  khal = prev.khal.overrideAttrs {
    sphinxBuilders = "html man";
  };
}
// prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  # Both hosts use this kernel package set through the Limine module.
  linuxPackages_latest = prev.linuxPackages_latest.extend (
    _kernelFinal: kernelPrev: {
      framework-laptop-kmod = kernelPrev.framework-laptop-kmod.overrideAttrs {
        # Standard installation generates the certificate for the module tree.
        installPhase = ''
          runHook preInstall
          make -C ${kernelPrev.kernel.dev}/lib/modules/${kernelPrev.kernel.modDirVersion}/build \
            M="$PWD" INSTALL_MOD_PATH="$out" INSTALL_MOD_DIR=extra \
            $makeFlags modules_install
          runHook postInstall
        '';
      };
    }
  );
}
