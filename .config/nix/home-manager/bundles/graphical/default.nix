{ config
, lib
, ...
}: {
  options.bundles.graphical = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The applications and desktop settings a host with a GNOME session gets";
    };
  };

  config = lib.mkIf config.bundles.graphical.enable {
    programs = {
      factorio.enable = true;
      gimp.enable = true;
      gnome.enable = true;
      gnome-browser-connector.enable = true;
      gnome-firmware.enable = true;
      gnome-network-displays.enable = true;
      gnome-power-manager.enable = true;
      gnome-tweaks.enable = true;
      helvum.enable = true;
      jadx.enable = true;
      logseq.enable = true;
      masterpdfeditor.enable = true;
      meld.enable = true;
      spotify.enable = true;
      theclicker.enable = true;
      transmission-remote-gtk.enable = true;
      transmission_4-gtk.enable = true;
      txomon-graphical.enable = true;
      vlc.enable = true;
      wine.enable = true;
      winetricks.enable = true;
      xdotool.enable = true;
    };
  };
}
