{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "vanta-agent";
  version = "2.18.0";

  # Vanta serves one .deb per version under a stable path. The file has been
  # re-uploaded since the AUR package pinned it (the S3 Last-Modified moved)
  # but the bytes still hash to the sha256 in the PKGBUILD, so the URL is
  # content-stable in practice. If a future version ever fails to fetch, the
  # version list lives at https://app.vanta.com/downloads.
  src = fetchurl {
    url = "https://agent-downloads.vanta.com/targets/versions/${version}/vanta-amd64.deb";
    hash = "sha256-Dm5YSJYjetEd2qW9Nt6NG1GnGuk9hMld1rmwyn3D9H0=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  # launcher, metalauncher, osquery-vanta.ext and vanta-cli are static Go
  # binaries; autoPatchelfHook skips them. Only osqueryd is dynamic, and it
  # needs nothing but glibc.
  #
  # Nothing here is stripped. These are signed, TUF-verified artefacts that
  # the metalauncher checks against the manifest it downloads, and rewriting
  # their section table is a good way to make that fail.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/libexec/vanta \
      var/vanta/launcher \
      var/vanta/metalauncher \
      var/vanta/osquery-vanta.ext \
      var/vanta/osqueryd \
      var/vanta/vanta-cli
    install -Dm644 var/vanta/cert.pem $out/libexec/vanta/cert.pem

    install -d $out/bin
    ln -s $out/libexec/vanta/vanta-cli $out/bin/vanta-cli

    install -Dm644 usr/share/doc/vanta/changelog.gz \
      $out/share/doc/vanta/changelog.gz

    # Upstream's unit, kept for reference only: its ExecStart is the
    # /var/vanta copy, not this one. See default.nix for the unit the system
    # layer has to declare.
    install -Dm644 usr/lib/systemd/system/vanta.service \
      $out/share/doc/vanta/vanta.service

    runHook postInstall
  '';

  meta = {
    description = "Vanta compliance monitoring agent";
    homepage = "https://www.vanta.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vanta-cli";
  };
}
