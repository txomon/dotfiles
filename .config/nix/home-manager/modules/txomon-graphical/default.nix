{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-graphical = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Short wrappers for desktop things that need a display";
    };
  };

  config = lib.mkIf config.programs.txomon-graphical.enable {
    home.packages = [
      # Migrated off Arch. Plain packages, no configuration of their own.
      pkgs.factorio
      pkgs.gimp
      pkgs.gnome-browser-connector
      pkgs.gnome-firmware
      pkgs.gnome-network-displays
      pkgs.gnome-power-manager
      pkgs.gnome-tweaks
      pkgs.helvum
      pkgs.jadx
      pkgs.logseq
      # The pinned nixpkgs has 5.9.98, whose tarball code-industry has since
      # removed: the URL 404s. They only serve the current release. Bumped to
      # 5.9.99, which is the version Arch is running and the one nixpkgs master
      # already moved to. The qt5 build, not the qt6 one the AUR uses, because
      # the rest of the derivation autoPatchelfs against libsForQt5.
      (pkgs.masterpdfeditor.overrideAttrs (final: prev: {
        version = "5.9.99";
        src = pkgs.fetchurl {
          url = "https://code-industry.net/public/master-pdf-editor-5.9.99-qt5.x86_64-qt_include.tar.gz";
          hash = "sha256-ksVuJyuImstESVwHUmOUv6aERosg6g5bSsRvPSf5EVM=";
        };
      }))
      pkgs.meld
      pkgs.spotify
      # Synthesises X11 clicks, so it is as display-bound as the rest here.
      pkgs.theclicker
      # transmission-gtk is a throw; 3 was dropped and 4 is a separate attribute.
      # Arch already ships 4.1.3, which is what this resolves to, so no data migration.
      pkgs.transmission_4-gtk
      pkgs.transmission-remote-gtk
      pkgs.vlc
      # pkgs.wine at 11.0 is built 32-bit only: lib/wine/ has i386-unix and
      # i386-windows and nothing else, so it cannot run an x64 Windows binary
      # or a win64 prefix. wineWow64Packages.stable is the same 11.0 with
      # x86_64-unix and x86_64-windows, which is what pCon.planner needs.
      pkgs.wineWow64Packages.stable
      pkgs.winetricks
      # Already in the closure as a runtimeInput of xcc and xcp below, but
      # those wrappers put it on PATH under their own names only. This is the
      # one that makes `xclip` itself callable, and it belongs next to its
      # wrappers rather than in a generic list.
      pkgs.xclip
      pkgs.xdotool

      (pkgs.writeShellApplication {
        name = "open";
        runtimeInputs = [ pkgs.xdg-utils ];
        text = ''exec xdg-open "$@"'';
      })

      (pkgs.writeShellApplication {
        name = "xcc";
        runtimeInputs = [ pkgs.xclip ];
        text = ''exec xclip -selection clipboard "$@"'';
      })

      (pkgs.writeShellApplication {
        name = "xcp";
        runtimeInputs = [ pkgs.xclip ];
        text = ''exec xclip -selection primary "$@"'';
      })
    ];
  };
}
