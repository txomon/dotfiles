{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, ydotool
, glib
, xorg
, coreutils
, procps
}:
let
  # The binary shells out to these by bare name. PATH is suffixed rather than
  # prefixed so the running session's own copies win: ydotool has to match the
  # ydotoold already listening on the uinput socket, and gsettings has to see
  # the session's schemas. These are only the fallback for a host that has
  # none of them.
  runtimeTools = [
    ydotool
    glib # gdbus, gsettings
    xorg.xprop # i3 backend only
    coreutils # id
    procps # ps
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "computer-use-linux";
  # No release tag on this commit; v0.2.4 plus three. Pinned to the same rev
  # the AUR package was built from, 0.2.4.r32.gc8201c8.
  version = "0.2.4-unstable-2026-05-30";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    rev = "c8201c8e0740ec927a945920439d31fdb3528846";
    hash = "sha256-CjBuDP1QT7hkJchsQymQNBd4nDQRhV2rB8e1N/iaNBs=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  # No C dependencies. wayland-client is left on wayland-backend's pure-Rust
  # implementation here, so nothing links or dlopens libwayland-client, and
  # atspi talks AT-SPI over zbus rather than through libatspi. The AUR
  # PKGBUILD lists wayland and pkgconf anyway; neither is reached.
  nativeBuildInputs = [ makeWrapper ];

  # The suite drives a real session: AT-SPI, the portals and a compositor.
  # In the sandbox every one of those tests fails on a missing bus. The AUR
  # PKGBUILD runs them with `|| true` for the same reason.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/computer-use-linux \
      --suffix PATH : ${lib.makeBinPath runtimeTools}

    ext=$out/share/gnome-shell/extensions/computer-use-linux@avifenesh.dev
    install -Dm644 -t $ext \
      "gnome-shell-extension/computer-use-linux@avifenesh.dev/metadata.json" \
      "gnome-shell-extension/computer-use-linux@avifenesh.dev/extension.js"
  '';

  meta = {
    description = "Linux desktop control over MCP: AT-SPI tree, compositor window targeting, portal screenshots, ydotool input";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "computer-use-linux";
  };
}
