{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gsconnect;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "gsconnect@andyholmes.github.io";
in
{
  options.programs.gsconnect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "KDE Connect for GNOME: phone notifications, file transfer and remote input";
    };

    # Pairing is peer to peer on the local network, so it needs inbound
    # 1714-1764 on both TCP and UDP. That is a firewall rule and lives in
    # nixos/modules/networking.nix, not here.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "gsconnect" ] { };
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
