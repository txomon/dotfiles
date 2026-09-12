{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.appindicator;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "appindicatorsupport@rgcjonas.gmail.com";
in
{
  options.programs.appindicator = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Tray icons for applications that speak AppIndicator or StatusNotifierItem";
    };

    # GNOME dropped the legacy tray in 3.26 and never replaced it. Slack,
    # Telegram and Discord all still expect one, so without this their windows
    # close to nothing instead of minimising to a tray icon.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "appindicator" ] { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Also linked into XDG_DATA_HOME, the same as modules/ringboard. A running
    # GNOME Shell reads XDG_DATA_DIRS once at startup, so an extension that
    # only arrives via the profile is invisible until the session restarts;
    # ~/.local/share/gnome-shell/extensions it watches.
    xdg.dataFile = lib.mkIf config.programs.gnome.enable {
      "gnome-shell/extensions/${uuid}".source =
        "${cfg.package}/share/gnome-shell/extensions/${uuid}";
    };
  };
}
