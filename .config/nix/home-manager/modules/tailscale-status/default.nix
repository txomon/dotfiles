{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.tailscale-status;

  # The directory name GNOME looks for, and the string that has to appear in
  # dconf's enabled-extensions. modules/gnome sets that list.
  uuid = "tailscale-status@maxgallup.github.com";
in
{
  options.programs.tailscale-status = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Tailnet peers and exit-node switching from the panel";
    };

    # Shells out to `tailscale` by bare name, so it needs the CLI on the
    # session PATH. It is not added here on purpose: the CLI talks to a running
    # tailscaled over its socket and the two should be the same build, which
    # means the one the system installs, from nixos/modules/tailscale.nix.
    package = lib.mkPackageOption pkgs [ "gnomeExtensions" "tailscale-status" ] { };
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
