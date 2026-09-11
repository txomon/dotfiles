{ config
, lib
, pkgs
, ...
}:
let
  gv = lib.hm.gvariant;
in
{
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
      pkgs.wine
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

    # GNOME keeps its settings in a binary database rather than files, so this
    # is the only way to declare them. Every key here was checked against its
    # schema default; keys an application had written but left at the default
    # are not repeated.
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-animations = false;
        show-battery-percentage = true;
      };

      "org/gnome/desktop/calendar".show-weekdate = true;
      "org/gnome/desktop/datetime".automatic-timezone = true;
      "org/gnome/desktop/sound".event-sounds = false;
      "org/gnome/desktop/notifications".show-in-lock-screen = false;
      "org/gnome/desktop/wm/preferences".num-workspaces = 1;

      # Unbound on purpose. An empty nix list already carries the "as" type.
      "org/gnome/desktop/wm/keybindings".activate-window-menu = [ ];

      "org/gnome/mutter" = {
        attach-modal-dialogs = false;
        dynamic-workspaces = false;
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      "org/gnome/desktop/input-sources" = {
        sources = [ (gv.mkTuple [ "xkb" "eu" ]) ];
        show-all-sources = true;
      };

      "org/gnome/desktop/peripherals/keyboard".numlock-state = true;

      "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = true;
        speed = 0.4238683127572016;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
        disable-while-typing = false;
        speed = 0.390727969348659;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };

      "org/gnome/settings-daemon/plugins/color".night-light-schedule-automatic = false;

      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
        sort-column = "name";
      };

      "org/gnome/nautilus/preferences".default-folder-viewer = "list-view";
      "org/gnome/nautilus/list-view".default-zoom-level = "small";
      "org/gnome/nautilus/compression".default-compression-format = "tar.xz";

      "org/gnome/calculator" = {
        button-mode = "programming";
        accuracy = 17;
        number-format = "fixed";
      };

      "org/gnome/meld" = {
        prefer-dark-theme = true;
        style-scheme = "meld-dark";
        vc-merge-file-order = "local-merge-remote";
      };

      "org/gnome/Console" = {
        font-scale = 1.1000000000000001;
        theme = "auto";
      };

      "org/gnome/Totem".subtitle-encoding = "UTF-8";

      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "kgx";
        name = "Terminal";
      };

      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "org.telegram.desktop.desktop"
          "goland.desktop"
          "slack.desktop"
        ];

        # Only ringboard is packaged here. The rest still come from
        # ~/.local/share/gnome-shell/extensions or the system extension set,
        # and GNOME ignores an entry it cannot find.
        enabled-extensions = [
          "gsconnect@andyholmes.github.io"
          "system-monitor@gnome-shell-extensions.gcampax.github.com"
          "notification-timeout@chlumskyvaclav.gmail.com"
          "tailscale-status@maxgallup.github.com"
          "panel-date-format@keiii.github.com"
          "ringboard@clipboard-history"
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
      };

      "org/gnome/shell/extensions/system-monitor" = {
        show-memory = true;
        show-swap = false;
      };

      "org/gnome/shell/extensions/notification-timeout".timeout = 5000;
      "org/gnome/shell/extensions/panel-date-format".format = "%Y-%m-%d %H:%M:%S %a %b";
    };
  };
}
