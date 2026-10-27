_final: prev:
{
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
