{ lib
, stdenvNoCC
, fetchurl
, dpkg
, jdk21
, makeWrapper
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "configuradorfnmt";
  version = "5.1.2";

  src = fetchurl {
    url = "https://descargas.cert.fnmt.es/Linux/configuradorfnmt_${finalAttrs.version}.amd64.deb";
    hash = "sha256-kAVzQ3hNbfi7rZ3OexO1O8W1i2wbb6WXuwixbX8CtgY=";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  # The .deb bundles Temurin 21 under usr/lib/configuradorfnmt/jre and every
  # class file in the jar tops out at major version 65, so jdk21 is the version
  # upstream actually ships against. The AUR package asks for java-runtime>=22,
  # which no artefact in the .deb requires.
  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/java/configuradorfnmt \
      usr/lib/configuradorfnmt/configuradorfnmt.jar \
      usr/lib/configuradorfnmt/bc-fips.jar \
      usr/lib/configuradorfnmt/bcutil-fips.jar \
      usr/lib/configuradorfnmt/bcpkix-fips.jar

    install -Dm644 usr/lib/configuradorfnmt/configuradorfnmt.png \
      $out/share/icons/hicolor/64x64/apps/configuradorfnmt.png

    install -Dm644 usr/share/doc/configuradorfnmt/copyright \
      $out/share/licenses/configuradorfnmt/LICENSE

    # Upstream's own launcher runs the main class off an explicit classpath with
    # no extra JVM flags, so a wrapper around java is the whole program. The
    # jar's manifest also carries Add-Exports and Add-Opens for jdk-internal
    # security packages, which -classpath ignores; no class in any of the four
    # jars references those packages, and the PKCS#11 code reaches the provider
    # through the public Security.getProvider/Provider.configure API, so
    # nothing is lost by not running it with -jar.
    cp=$out/share/java/configuradorfnmt
    makeWrapper ${lib.getExe' jdk21 "java"} $out/bin/configuradorfnmt \
      --add-flags "-classpath $cp/configuradorfnmt.jar:$cp/bc-fips.jar:$cp/bcutil-fips.jar:$cp/bcpkix-fips.jar" \
      --add-flags es.gob.fnmt.cert.certrequest.CertRequest

    # The .desktop file in the .deb points Icon= and Exec= at absolute /usr
    # paths, so it is rewritten rather than installed. StartupWMClass is
    # upstream's value; the rest matches the AUR copy.
    mkdir -p $out/share/applications
    cat > $out/share/applications/configuradorfnmt.desktop <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=Configurador FNMT
    Comment=Aplicación FNMT para la descarga e instalación de certificados
    Exec=configuradorfnmt %U
    Icon=configuradorfnmt
    Terminal=false
    StartupNotify=true
    StartupWMClass=configuradorfnmt
    MimeType=x-scheme-handler/fnmtcr;
    Categories=System;Security;
    Keywords=FNMT;certificate;
    EOF

    runHook postInstall
  '';

  meta = {
    description = "FNMT-RCM tool to request keys and certificates";
    homepage = "https://www.sede.fnmt.gob.es/descargas/descarga-software/instalacion-software-generacion-de-claves";
    # Proprietary EULA, shipped as usr/share/doc/configuradorfnmt/copyright.
    license = {
      shortName = "FNMT-EULA";
      fullName = "FNMT-RCM Acuerdo de Licencia de Usuario Final";
      url = "https://www.sede.fnmt.gob.es/descargas/descarga-software";
      free = false;
    };
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "configuradorfnmt";
  };
})
