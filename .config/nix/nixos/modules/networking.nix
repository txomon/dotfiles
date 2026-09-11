{ hostname, ... }: {
  networking.hostName = hostname;

  # GNOME expects NetworkManager; nm-applet and the shell status menu talk to it.
  networking.networkmanager.enable = true;

  # networking.firewall.enable defaults to true. mosh is in the package list and
  # needs an inbound UDP range to accept sessions; uncomment if this host is a
  # mosh server rather than only a client.
  # networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
}
