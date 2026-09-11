{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.computer-use-linux;
in
{
  options.programs.computer-use-linux = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "MCP server for driving the Linux desktop";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The computer-use-linux build to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Same reasoning as ringboard: a running GNOME Shell watches
    # XDG_DATA_HOME, not the profile's XDG_DATA_DIRS, so the extension goes
    # where the shell will see it. Only useful where there is a shell to load
    # it, which is what txomon-graphical means.
    xdg.dataFile = lib.mkIf config.programs.txomon-graphical.enable {
      "gnome-shell/extensions/computer-use-linux@avifenesh.dev".source =
        "${cfg.package}/share/gnome-shell/extensions/computer-use-linux@avifenesh.dev";
    };

    # Three things this module deliberately does not do, because they are
    # system state rather than user config:
    #
    # * /dev/uinput access. ydotoold needs it, which means a udev rule and
    #   membership of the input group:
    #     services.udev.extraRules = ''
    #       KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    #     '';
    #     users.users.javier.extraGroups = [ "input" ];
    # * the ydotoold daemon, which NixOS has as programs.ydotool.enable.
    # * gnome-extensions enable computer-use-linux@avifenesh.dev, which writes
    #   to the user's dconf and is a one-off after first login.
    #
    # The binary's PATH is suffixed rather than prefixed, so whatever the
    # session already provides (its own ydotool, hyprctl, i3-msg, qdbus6,
    # gnome-extensions, systemctl) wins over the store copies. Those last five
    # are not in the closure at all: the desktop that needs them ships them.
  };
}
