{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.system-monitor;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "system-monitor@gnome-shell-extensions.gcampax.github.com";
in
{
  options.programs.system-monitor = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "CPU, memory and network in the top bar";
    };

    # The gcampax one from the official gnome-shell-extensions set, not the
    # unrelated third-party extension of the same name. The uuid above is what
    # tells them apart. modules/gnome turns memory on and swap off.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "system-monitor" ] { };
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
