{ ... }: {
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # services.gnome.core-apps.enable defaults to true and pulls in the ~29
  # package GNOME core app set (Files, Calendar, Text Editor, Console, and so
  # on). Left on: the GNOME apps are wanted.

  services.printing.enable = true;

  hardware.graphics.enable = true;

  # PipeWire, with the PulseAudio server it replaces switched off.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
