{ lib
, stdenvNoCC
, requireFile
, symlinkJoin
, writeShellApplication
, msitools
, icoutils
, pkgsCross
, wineWow64Packages
, winetricks
, coreutils
, procps
}:

let
  pname = "pcon-planner";
  version = "8.15";

  # EasternGraphics ships one URL per minor version, but not one file. The
  # installer served from it on 2026-09-11 is 436354648 bytes; the one this
  # recipe was developed and verified against is 417655400 bytes (FileVersion
  # 8.15.0.100, built 2025-07-08), and their PE headers differ. Same version,
  # same path, different build, so fetchurl cannot pin it.
  #
  # Getting the product MSI out of that .exe needs ISx (github.com/lifenjoiner/ISx),
  # Windows-only C that also wants miniz, run under Wine, because the payload is an
  # ISSetupStream container with no plain MSI inside it to carve out. That step
  # is both impure and Wine-dependent, so the nix boundary sits at the MSI: from
  # there msiextract reproduces the program tree natively, byte for byte.
  # Renamed on the way in: MSI ships as "pCon.planner STD 8.15.msi" and store
  # path names cannot contain spaces.
  msi = requireFile {
    name = "pCon.planner-STD-8.15.msi";
    sha256 = "07q5wk4jnlc033f2jm053q121z06ay2zp3d7fpxkly7v72kc4fb7";
    message = ''
      pCon.planner's product MSI is not fetchable reproducibly, so it has to be
      added to the store by hand, once:

        1. Download the installer:
           https://downloads.pcon-solutions.com/pCon/planner/8.15/pCon.planner_Std_Installer.exe

        2. Extract the MSI from it with ISx (github.com/lifenjoiner/ISx), built
           for Windows and run under Wine. It writes to <installer>_u/:
             wine ISx.exe pCon.planner_Std_Installer.exe

        3. Add the result to the store under a space-free name:
             cp '<installer>_u/pCon.planner STD 8.15.msi' pCon.planner-STD-8.15.msi
             nix-store --add-fixed sha256 pCon.planner-STD-8.15.msi

      Note that EasternGraphics re-rolls the installer under the same URL, so a
      fresh download will not match this hash.
    '';
  };

  # pCon needs two Wine fixes that pull in opposite directions, and only staging
  # carries both: ntdll-ForceBottomUpAlloc, without which native msxml6 faults in
  # DllMain and pCon dies with "Runtime error 217" (WineHQ 46568), and the PE-side
  # WGL rework that fixes wglShareLists for pCon's shared multi-viewport GL
  # contexts (WineHQ 58506, regressed 10.13, fixed 11.7+). Proton 11 still has the
  # WGL bug, so a Proton base breaks the 3D.
  #
  # base.nix applies the staging patchset in prePatch and `patches` in patchPhase,
  # so these land on top of staging. All three are stock-Wine gaps, upstreamable,
  # and droppable once WineHQ merges them.
  wine = wineWow64Packages.stagingFull.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./wine-fixes/0001-wbemdisp-property-enumeration.patch
      ./wine-fixes/0002-rtscom-stylus-sync-plugins.patch
      ./wine-fixes/0003-shell32-system-imagelist-fallback.patch
    ];
  });

  # pCon 8.15 embeds WebView2 for its online catalog, start page and PIM. The
  # runtime is absent under Wine, and Tx3gWebView answers a failed init by
  # re-entering navigate() in line, forever, until the main thread's stack
  # overflows, which is why any modal dialog froze the app. This stub reports
  # WebView2 present and then leaves the environment permanently "initializing":
  # never calling the completion handler makes pCon wait instead of retry.
  #
  # It replaces a DLL pCon ships, not one of pCon's own binaries. planner.exe
  # verifies its own Authenticode signature and exits if touched, so every fix
  # here has to sit beside it rather than in it.
  webview2LoaderStub = pkgsCross.mingwW64.stdenv.mkDerivation {
    pname = "webview2loader-stub";
    inherit version;

    src = ./webview2loader-stub;

    buildPhase = ''
      runHook preBuild
      $CC -shared -O2 -o WebView2Loader.dll \
        WebView2Loader-stub.c WebView2Loader.def -lole32
      $STRIP WebView2Loader.dll
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 WebView2Loader.dll $out/bin/WebView2Loader.dll
      runHook postInstall
    '';
  };

  # msiextract runs the file table only, so it sidesteps both InstallShield
  # deadlocks: the ISSetupStream launcher's /waitingforchildprocess handshake and
  # the InstallScript custom actions, each of which hangs forever under Wine.
  # Verified to reproduce the 718-file tree that pCon 8.15 was proven to run from.
  appTree = stdenvNoCC.mkDerivation {
    pname = "${pname}-app";
    inherit version;
    src = msi;

    nativeBuildInputs = [ msitools icoutils ];

    dontUnpack = true;
    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p tree
      msiextract -C tree "$src"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -d $out/share/pcon-planner
      cp -a "tree/Program Files 64/EasternGraphics" $out/share/pcon-planner/

      bin="$out/share/pcon-planner/EasternGraphics/pCon.planner STD/bin"
      install -Dm644 ${webview2LoaderStub}/bin/WebView2Loader.dll \
        "$bin/WebView2Loader.dll"

      # Upstream's .desktop names an icon it never installs. planner.exe carries
      # one as MAINICON, in seven sizes. icotool writes a plain file rather than
      # a directory if the target is missing, and the loop below would then be
      # skipped silently by nullglob, so the directory is created up front and
      # the result asserted.
      mkdir -p icons
      wrestool -x -t 14 -n MAINICON -o pcon.ico "$bin/planner.exe"
      icotool -x -o icons pcon.ico

      # icotool names its output <base>_<index>_<width>x<height>x<depth>.png, and
      # the depth is dropped rather than assumed to be 32.
      for png in icons/*.png; do
        size=''${png##*_}
        size=''${size%x*.png}
        install -Dm644 "$png" \
          $out/share/icons/hicolor/$size/apps/pcon-planner.png
      done
      [ -d $out/share/icons ] || { echo "no icon extracted from planner.exe" >&2; exit 1; }

      mkdir -p $out/share/applications
      cat > $out/share/applications/pcon-planner.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=pCon.planner
      GenericName=CAD / Interior Planner
      Comment=EasternGraphics pCon.planner 8.15 (under Wine)
      Exec=pcon-planner %f
      Icon=pcon-planner
      Terminal=false
      Categories=Graphics;Engineering;
      MimeType=image/vnd.dwg;application/dxf;
      StartupWMClass=planner.exe
      Keywords=cad;dwg;interior;furniture;planning;3d;
      EOF

      runHook postInstall
    '';
  };

  # A Wine prefix is mutable per-user state, so it cannot live in the store. It
  # is provisioned under the user's data dir on first run and the read-only app
  # tree is mapped into it.
  launcher = writeShellApplication {
    name = "pcon-planner";

    runtimeInputs = [ coreutils procps wine winetricks ];

    text = ''
      app_dir="${appTree}/share/pcon-planner/EasternGraphics"
      exe='C:\Program Files\EasternGraphics\pCon.planner STD\bin\planner.exe'

      export WINEARCH=win64
      export WINEPREFIX="''${WINEPREFIX:-''${XDG_DATA_HOME:-''${HOME}/.local/share}/pcon-planner/prefix}"
      export WINEDEBUG="''${WINEDEBUG:--all}"

      # wineboot on a fresh prefix hangs in `rundll32 setupapi,InstallHinfSection`
      # and never returns. Reaping that one process lets wineboot finish; the
      # bracket keeps pgrep's own pattern from matching itself. Both the pgrep and
      # the kill race a process that may have exited on its own, which is the one
      # thing here allowed to fail quietly.
      reap_hinf_hang() {
        local pids i
        for ((i = 0; i < 60; i++)); do
          pids=$(pgrep -f 'setupapi,[I]nstallHinfSection' || true)
          if [ -n "''${pids}" ]; then
            # shellcheck disable=SC2086
            kill ''${pids} 2>/dev/null || true
          fi
          sleep 1
        done
      }

      provision() {
        echo "pcon-planner: provisioning Wine prefix at ''${WINEPREFIX} (one-time)" >&2

        reap_hinf_hang &
        local reaper=$!
        # The reaper kills by pattern, so it must not outlive this function even
        # if wineboot is interrupted.
        trap 'kill "''${reaper}" 2>/dev/null || true' RETURN INT TERM
        wineboot -i
        wineserver -w

        # Downloads Microsoft redistributables, so the first run needs network.
        # mscoree is disabled for the duration so winetricks does not trip the
        # Wine Mono installer dialog while removing Mono.
        WINEDLLOVERRIDES="mscoree=" winetricks -q --unattended \
          remove_mono dotnet48 vcrun2022 msxml3 msxml6

        # msxml6 keeps builtin as a fallback because the native DLL only loads
        # once staging's ForceBottomUpAlloc has kept the address space low.
        wine reg add 'HKCU\Software\Wine\DllOverrides' /v '*mscoree' /d native /f
        wine reg add 'HKCU\Software\Wine\DllOverrides' /v '*msxml3' /d native /f
        wine reg add 'HKCU\Software\Wine\DllOverrides' /v '*msxml4' /d native /f
        wine reg add 'HKCU\Software\Wine\DllOverrides' /v '*msxml6' /d 'native,builtin' /f
        # Empty disables the DLL, which is what stops the Gecko install prompt.
        wine reg add 'HKCU\Software\Wine\DllOverrides' /v 'mshtml' /d "" /f
        wineserver -w

        touch "''${WINEPREFIX}/.pcon-provisioned"
        echo "pcon-planner: prefix ready." >&2
      }

      [ -f "''${WINEPREFIX}/.pcon-provisioned" ] || provision

      # Refreshed every run, not just at provision time: the store path changes
      # whenever the package is rebuilt, and a stale symlink points at a garbage
      # collected tree.
      prefix_pf="''${WINEPREFIX}/drive_c/Program Files"
      mkdir -p "''${prefix_pf}"
      ln -sfn "''${app_dir}" "''${prefix_pf}/EasternGraphics"

      # Opening a drawing on the command line imports it with silent defaults.
      # Doing it through pCon's own File->Open raises the DWG scaling dialog,
      # which is one of the modal paths the WebView2 stub exists to survive.
      #
      # Only real paths are translated; anything else is a pCon switch and is
      # passed through as typed.
      args=()
      for arg in "$@"; do
        if [ -e "''${arg}" ]; then
          args+=("$(winepath -w "''${arg}")")
        else
          args+=("''${arg}")
        fi
      done

      exec wine "''${exe}" "''${args[@]}"
    '';
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ appTree launcher ];

  meta = {
    description = "pCon.planner 8.15 Standard, EasternGraphics' CAD planner, under Wine";
    homepage = "https://pcon-planner.com/";
    license = {
      fullName = "pCon.planner End User License Agreement";
      url = "https://pcon-solutions.com/en/terms-of-use/";
      free = false;
    };
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "pcon-planner";
    # requireFile: nothing can build this without the MSI already in the store.
    hydraPlatforms = [ ];
  };
}
