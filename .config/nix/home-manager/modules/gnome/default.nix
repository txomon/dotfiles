{ config
, lib
, ...
}:
let
  gv = lib.hm.gvariant;
in
{
  options.programs.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GNOME desktop settings, and the marker that this host runs GNOME Shell";
    };
  };

  config = lib.mkIf config.programs.gnome.enable {
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

        # All seven are packaged, one module each, and every one of those
        # modules links its extension into ~/.local/share/gnome-shell/
        # extensions. GNOME ignores an entry here it cannot find, so this list
        # and the enables in bundles/graphical have to agree; nothing checks
        # that they do.
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
