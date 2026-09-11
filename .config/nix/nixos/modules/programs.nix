{ pkgs, ... }: {
  # Creates the `wireshark` group and a setcap dumpcap wrapper owned by it, so
  # members can capture without running the GUI as root. The package option
  # defaults to wireshark-cli; pkgs.wireshark is the Qt build.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Pulls in the FHS wrapper, the 32-bit graphics stack and the steam-hardware
  # udev rules for controllers.
  programs.steam.enable = true;

  # The XP-Pen tablet driver. The module installs the package, registers its
  # udev rules through services.udev.packages, turns on hardware.uinput and
  # seeds /var/lib/pentablet, which the driver writes to at runtime.
  programs.xppen.enable = true;
}
