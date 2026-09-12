{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.panel-date-format;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "panel-date-format@keiii.github.com";
in
{
  options.programs.panel-date-format = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "A strftime format string for the panel clock";
    };

    # The format itself is in modules/gnome, not here, because it is a
    # setting and this is the package.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "panel-date-format" ] { };
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
