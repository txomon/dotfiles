{ lib
, fetchFromGitHub
, fetchurl
, maven
, symlinkJoin
, writeShellApplication
, coreutils
, gnugrep
, openssl
, nss
, jdk17
}:

let
  pname = "autofirma";
  version = "1.9.2";

  # The oldest timestamp a zip entry can hold, which is what nix uses for
  # SOURCE_DATE_EPOCH. Both spellings describe the same instant.
  mavenEpoch = "1980-01-02T00:00:00Z";
  mavenEpochStamp = "19800102000000";

  # afirma-simple asks for org.java-websocket:Java-WebSocket:1.6.1-SNAPSHOT,
  # which was never published to Maven Central. Upstream issue 320. This is the
  # commit whose pom carries that exact version; it has to be installed into the
  # local repository before the app resolves, so there is no way around it.
  javaWebsocketRev = "8c5766a293c2dd3e0d035c0e0d70f88f57235fa8";

  javaWebsocketSrc = fetchurl {
    url = "https://github.com/TooTallNate/Java-WebSocket/archive/${javaWebsocketRev}.tar.gz";
    hash = "sha256-2luiVOEtLn/YpYsw/UyLqnvciT76Y6P7WNoXG7yFhUI=";
  };

  # Upstream issue 479: AutoFirma's own "restaurar instalación" action only
  # looks for Firefox profiles under ~/.mozilla, so it misses a Firefox that has
  # moved to the XDG path. Still unmerged at v1.9.2 and still applies cleanly.
  firefoxProfilePathsPatch = fetchurl {
    url = "https://patch-diff.githubusercontent.com/raw/ctt-gob-es/clienteafirma/pull/487.patch";
    hash = "sha256-+9/nGTNISZlHyjVVJuWhpOn2+GojlaeRle+9CdIG3Ow=";
  };

  # -Denv=install turns off the activeByDefault env-dev profile, so only the
  # five application modules build here; the afirma-* libraries they import are
  # pinned to 1.9 and come from Maven Central.
  app = maven.buildMavenPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ctt-gob-es";
      repo = "clienteafirma";
      tag = "v${version}";
      hash = "sha256-GnZtuAG7ogbvX5EH7lg0z8imja/ZoNVw9qT3qoCRIn0=";
    };

    patches = [ firefoxProfilePathsPatch ];

    # The poms compile with -source 1.8, which jdk17 still accepts and newer
    # JDKs do not. It is also the runtime upstream's own packaging recommends.
    mvnJdk = jdk17;
    mvnParameters = "-Denv=install -Dmaven.test.skip=true";
    doCheck = false;

    mvnFetchExtraArgs = {
      preBuild = ''
        mkdir -p java-websocket
        tar xzf ${javaWebsocketSrc} -C java-websocket --strip-components=1
        ( cd java-websocket
          mvn -B -Dmaven.repo.local=$out/.m2 -Dmaven.test.skip=true \
            -Dproject.build.outputTimestamp=${mavenEpoch} install
        )
      '';

      # This is a fixed-output derivation, so nothing it writes may follow the
      # clock, and mvn install stamps the local metadata with the wall clock.
      #
      # The two maven-metadata-central.xml files stay. They carry Central's own
      # index of bouncycastle, which an es.gob.afirma:1.9 pom asks for as the
      # range [1.80,1.81); deleting them fails the offline build with "No
      # versions available ... within specified range". Their content only
      # moves when bouncycastle publishes, and that is when mvnHash needs
      # refreshing.
      postInstall = ''
        find $out -name maven-metadata-local.xml -exec sed -i -E \
          -e 's#<lastUpdated>[0-9]+</lastUpdated>#<lastUpdated>${mavenEpochStamp}</lastUpdated>#g' \
          -e 's#<updated>[0-9]+</updated>#<updated>${mavenEpochStamp}</updated>#g' \
          '{}' +
      '';
    };
    mvnHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    installPhase = ''
      runHook preInstall

      install -Dm644 afirma-simple/target/autofirma.jar \
        $out/share/java/autofirma/autofirma.jar

      install -Dm644 \
        afirma-simple-installer/linux/instalador_rpm_suse/rpmbuild/BUILD/autofirma.svg \
        $out/share/icons/hicolor/scalable/apps/autofirma.svg

      install -Dm644 license/LICENSE.txt $out/share/licenses/autofirma/LICENSE

      # Upstream's .desktop files hardcode /usr paths in Exec and Icon.
      # MimeType and StartupWMClass are carried over unchanged: the browser
      # handoff uses the afirma: scheme, and GNOME matches the window by class.
      mkdir -p $out/share/applications
      cat > $out/share/applications/autofirma.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=AutoFirma
      Comment=Cliente @firma
      Icon=autofirma
      Exec=autofirma %U
      Terminal=false
      StartupNotify=true
      StartupWMClass=autofirma
      MimeType=x-scheme-handler/afirma;
      Categories=Utility;Java;
      EOF

      runHook postInstall
    '';
  };

  # AutoFirma talks to the browser over a localhost WebSocket, so it needs a
  # certificate for 127.0.0.1 that the browser trusts. SecureSocketUtils in the
  # jar hardcodes the keystore: PKCS12 named autofirma.pfx under
  # DesktopUtil.getApplicationDirectory(), with both the store and the key
  # password set to 654321. Upstream creates it from a .deb postinst running
  # autofirmaConfigurador.jar; there is no postinst here, so the launcher mints
  # it on first run and re-installs the CA on every run, because Firefox
  # profiles appear over time.
  launcher = writeShellApplication {
    name = "autofirma";

    runtimeInputs = [ coreutils gnugrep openssl nss.tools jdk17 ];

    text = ''
      autofirma_jar="${app}/share/java/autofirma/autofirma.jar"

      autofirma_dir="''${HOME}/.afirma/Autofirma"
      autofirma_ca="''${autofirma_dir}/AutoFirma_ROOT.cer"
      autofirma_pfx="''${autofirma_dir}/autofirma.pfx"
      cert_days=3650
      cert_cn="AutoFirma ROOT"
      nssdb_dir="''${HOME}/.pki/nssdb"
      new_firefox_config_dir="''${XDG_CONFIG_HOME:-''${HOME}/.config}/mozilla/firefox"
      legacy_firefox_config_dir="''${HOME}/.mozilla/firefox"
      temp_dir=

      make_ca_config() {
      # The heredoc body sits at column 0 because <<EOF does not strip indent.
      cat > "''${temp_dir}/openssl.cnf" <<EOF
      [ ca ]
      default_ca=CA_autofirma
      [ CA_autofirma ]
      dir=''${temp_dir}
      new_certs_dir=\$dir
      database=\$dir/index.txt
      serial=\$dir/serial
      crlnumber=\$dir/crlnumber
      default_days=''${cert_days}
      default_crl_days=30
      default_md=sha256
      preserve=no
      x509_extensions=usr_cert
      email_in_dn=no
      copy_extensions=copy
      [ policy_ca ]
      countryName=optional
      stateOrProvinceName=optional
      localityName=optional
      organizationName=optional
      organizationalUnitName=optional
      commonName=supplied
      emailAddress=optional
      [ req ]
      default_bits=4096
      x509_extensions=v3_ca
      distinguished_name=req_distinguished_name
      [ req_distinguished_name ]
      commonName_default=''${cert_cn}
      [ usr_cert ]
      basicConstraints=CA:FALSE
      subjectKeyIdentifier=hash
      authorityKeyIdentifier=keyid:always,issuer:always
      subjectAltName=IP:127.0.0.1
      [ v3_ca ]
      basicConstraints=critical,CA:TRUE
      subjectKeyIdentifier=hash
      authorityKeyIdentifier=keyid:always,issuer:always
      keyUsage=cRLSign,digitalSignature,keyCertSign,keyEncipherment,dataEncipherment
      extendedKeyUsage=serverAuth,clientAuth,anyExtendedKeyUsage
      EOF
        touch "''${temp_dir}/index.txt"
        echo "01" > "''${temp_dir}/crlnumber"
      }

      do_init() {
        mkdir -p "''${autofirma_dir}"
        temp_dir="$(mktemp -d)"
        trap 'rm -rf "''${temp_dir}"' EXIT
        rm -f "''${autofirma_ca}" "''${autofirma_pfx}"
        make_ca_config
        openssl rand -base64 48 > "''${temp_dir}/randomkey.txt"

        openssl req -config "''${temp_dir}/openssl.cnf" -new \
          -passout file:"''${temp_dir}/randomkey.txt" \
          -keyout "''${temp_dir}/autofirma.key" \
          -subj "/CN=''${cert_cn}" \
          -out "''${temp_dir}/autofirma.csr"
        openssl ca -config "''${temp_dir}/openssl.cnf" -batch -create_serial \
          -notext -selfsign \
          -extensions v3_ca \
          -policy policy_ca \
          -out "''${autofirma_ca}" \
          -days "''${cert_days}" \
          -passin file:"''${temp_dir}/randomkey.txt" \
          -keyfile "''${temp_dir}/autofirma.key" \
          -infiles "''${temp_dir}/autofirma.csr"

        openssl req -config "''${temp_dir}/openssl.cnf" -new \
          -passout file:"''${temp_dir}/randomkey.txt" \
          -keyout "''${temp_dir}/user.key" \
          -subj "/CN=127.0.0.1" \
          -out "''${temp_dir}/user.csr"
        openssl ca -config "''${temp_dir}/openssl.cnf" -batch -notext \
          -extensions usr_cert \
          -policy policy_ca \
          -out "''${temp_dir}/user.cer" \
          -cert "''${autofirma_ca}" \
          -keyfile "''${temp_dir}/autofirma.key" \
          -passin file:"''${temp_dir}/randomkey.txt" \
          -infiles "''${temp_dir}/user.csr"

        openssl pkcs12 -export \
          -passin file:"''${temp_dir}/randomkey.txt" \
          -inkey "''${temp_dir}/user.key" \
          -certfile "''${autofirma_ca}" \
          -in "''${temp_dir}/user.cer" \
          -name "socketautofirma" \
          -passout pass:654321 \
          -out "''${autofirma_pfx}"

        # The CA private key must not outlive this function.
        rm -rf "''${temp_dir}"
        trap - EXIT
      }

      # sql: is explicit rather than relying on the NSS default, which the
      # caller can still flip with NSS_DEFAULT_DB_TYPE. Firefox and Chrome have
      # both read cert9.db only for years.
      install_ca() {
        # -D removes a previous copy so -A never collides. It exits non-zero
        # when the nickname is absent, which is the normal first-run case.
        certutil -d "sql:$1" -D -n "''${cert_cn}" > /dev/null 2>&1 || true
        certutil -d "sql:$1" -A -i "''${autofirma_ca}" -n "''${cert_cn}" -t C,,
      }

      add_ca_to_firefox() {
        local config_dir="$1"
        local profiles_ini="$1/profiles.ini"
        local line profile_path

        [ -r "''${profiles_ini}" ] || return 0

        # grep exits 1 when profiles.ini lists no profile at all.
        while IFS= read -r line; do
          profile_path="''${line##*=}"
          # Path= is relative to the config dir unless IsRelative=0, in which
          # case it is absolute. Testing the leading slash keeps the answer out
          # of the working directory the launcher happened to start in.
          case "''${profile_path}" in
            /*) ;;
            *) profile_path="''${config_dir}/''${profile_path}" ;;
          esac
          if [ -d "''${profile_path}" ]; then
            install_ca "''${profile_path}"
          fi
        done < <(grep '^Path=' "''${profiles_ini}" || true)
      }

      trust_ca() {
        # The shared NSS database is only updated, never created: it belongs to
        # whichever browser made it. Both Firefox roots are scanned rather than
        # one or the other, because a profile left behind under ~/.mozilla
        # still gets opened. This is what PR 487 does for the copy of this
        # logic that lives inside the app.
        if [ -r "''${nssdb_dir}" ]; then
          install_ca "''${nssdb_dir}"
        fi
        if [ -r "''${new_firefox_config_dir}" ]; then
          add_ca_to_firefox "''${new_firefox_config_dir}"
        fi
        if [ -r "''${legacy_firefox_config_dir}" ]; then
          add_ca_to_firefox "''${legacy_firefox_config_dir}"
        fi
      }

      if [ ! -r "''${autofirma_ca}" ] || [ ! -r "''${autofirma_pfx}" ]; then
        do_init
      fi

      trust_ca

      # Every launcher upstream ships for this jar sets this: the Windows
      # launch4j configs, the Fedora and openSUSE specs, the .deb and the macOS
      # app delegate. Certificate chains from the AAPP sites overflow the 32K
      # default and the TLS handshake fails without it.
      exec java -Djdk.tls.maxHandshakeMessageSize=65536 -jar "''${autofirma_jar}" "$@"
    '';
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ app launcher ];

  meta = {
    description = "Cliente @firma, the Spanish government's electronic signature client";
    homepage = "https://firmaelectronica.gob.es/";
    license = with lib.licenses; [ gpl2Plus eupl11 ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.linux;
    mainProgram = "autofirma";
  };
}
