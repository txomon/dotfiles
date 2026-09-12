{ hostname, ... }: {
  networking.hostName = hostname;

  # GNOME expects NetworkManager; nm-applet and the shell status menu talk to it.
  networking.networkmanager.enable = true;

  # networking.firewall.enable defaults to true. mosh is in the package list and
  # needs an inbound UDP range to accept sessions; uncomment if this host is a
  # mosh server rather than only a client.
  # networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  # gsconnect pairs with a phone peer to peer on whatever LAN both are on, so
  # it needs this range inbound on TCP and UDP. Same range kdeconnect uses, and
  # nixpkgs' programs/kdeconnect.nix opens exactly it. That module is not used
  # here because it would also install the extension, which is home-manager's
  # job in modules/gsconnect; this file only opens the door.
  networking.firewall.allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
  networking.firewall.allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
}
