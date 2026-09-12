{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.notification-timeout;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "notification-timeout@chlumskyvaclav.gmail.com";
in
{
  options.programs.notification-timeout = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "One configurable timeout for every notification banner";
    };

    # The narrowest shell-version range of the set, 49 and 50 only, against
    # 45 to 50 for most of the others. It is the first one a GNOME bump will
    # drop. modules/gnome sets the timeout itself, to 5000ms.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "notification-timeout" ] { };
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
