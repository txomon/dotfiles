{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.ringboard;
in
{
  options.programs.ringboard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ringboard clipboard manager, txomon's D-Bus fork";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The ringboard build to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # GNOME Shell reads XDG_DATA_DIRS for extensions, but on a non-NixOS host
    # that list is rebuilt by the session and a profile swap goes unnoticed by
    # a running shell. XDG_DATA_HOME is a real directory it always watches.
    xdg.dataFile."gnome-shell/extensions/ringboard@clipboard-history".source =
      "${cfg.package}/share/gnome-shell/extensions/ringboard@clipboard-history";

    systemd.user.services.ringboard-server = {
      Unit = {
        Description = "Ringboard server";
        Documentation = "https://github.com/txomon/clipboard-history";
        # dbus::spawn() claims the well-known name once and never reconnects,
        # so the server must not outlive the bus it registered on.
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/ringboard-server";
        Restart = "on-failure";
        Slice = "ringboard.slice";
        Environment = [ "RUST_LOG=warn" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.slices.ringboard = {
      Unit.Description = "Slice for all Ringboard services.";
    };
  };
}
