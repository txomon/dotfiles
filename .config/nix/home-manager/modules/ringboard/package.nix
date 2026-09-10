{ lib
, stdenv
, dbus
, fetchFromGitHub
, fenix
, makeRustPlatform
, pkg-config
, makeWrapper
, glib
, libGL
, libxkbcommon
, wayland
, xorg
}:
let
  toolchain = fenix.minimal.toolchain;

  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };

  # ringboard-egui dlopens these at runtime rather than linking them, so they
  # have to be on the library path of the wrapper, not just in buildInputs.
  runtimeLibs = [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "ringboard";
  version = "0.17.0-dbus";

  src = fetchFromGitHub {
    owner = "txomon";
    repo = "clipboard-history";
    rev = "dae14e2c8a74d1319aae7890d47deed174eaa61f";
    hash = "sha256-F2QREVVgAVCR3AtkH0lgjd7ZR3CuNfgnUMggfJ3PBdc=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config makeWrapper glib ];
  buildInputs = runtimeLibs;

  # dbus_smoke.rs and dbus_reconnect.rs shell out to dbus-launch and
  # dbus-daemon. Without them the tests skip silently rather than fail.
  nativeCheckInputs = [ dbus ];

  # gnome-shell/ffi has a Cargo.toml but is not a workspace member; --workspace
  # skips it. The server's `dbus` feature is on by default, as is `systemd`,
  # which the unit's Type=notify depends on.
  cargoBuildFlags = [ "--workspace" "--bins" ];
  cargoTestFlags = [ "-p" "clipboard-history-server" ];

  postInstall = ''
    for b in ringboard-egui ringboard-tui; do
      wrapProgram $out/bin/$b \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
    done

    install -Dm644 server/ringboard-server.service \
      $out/share/systemd/user/ringboard-server.service
    install -Dm644 wayland/ringboard-wayland.service \
      $out/share/systemd/user/ringboard-wayland.service
    install -Dm644 x11/ringboard-x11.service \
      $out/share/systemd/user/ringboard-x11.service
    install -Dm644 ringboard.slice $out/share/systemd/user/ringboard.slice

    # The units call the binaries by bare name; point them at the store.
    substituteInPlace $out/share/systemd/user/*.service \
      --replace-fail 'ExecStart=ringboard-' "ExecStart=$out/bin/ringboard-"

    install -Dm644 egui/ringboard-egui.desktop \
      $out/share/applications/ringboard.desktop

    # The extension is not part of the cargo build. Ship only what GNOME loads:
    # the .pot, package.json and the test file are development files.
    ext=$out/share/gnome-shell/extensions/ringboard@clipboard-history
    install -Dm644 -t $ext \
      gnome-shell/extension/extension.js \
      gnome-shell/extension/prefs.js \
      gnome-shell/extension/confirmDialog.js \
      gnome-shell/extension/dataStructures.js \
      gnome-shell/extension/stylesheet.css \
      gnome-shell/extension/metadata.json
    install -Dm644 -t $ext/lib \
      gnome-shell/extension/lib/clipboardIntake.js \
      gnome-shell/extension/lib/dbusClient.js \
      gnome-shell/extension/lib/menuController.js \
      gnome-shell/extension/lib/mimePriority.js
    install -Dm644 -t $ext/schemas \
      gnome-shell/extension/schemas/org.gnome.shell.extensions.ringboard.gschema.xml
    glib-compile-schemas $ext/schemas
  '';

  meta = {
    description = "Ringboard clipboard manager, txomon's D-Bus fork";
    homepage = "https://github.com/txomon/clipboard-history";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "ringboard";
  };
}
