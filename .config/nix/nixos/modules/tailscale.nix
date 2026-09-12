{ ... }: {
  # The address every host is actually reached on. sam answers on
  # 100.72.138.16, rosita and pippin likewise, and all three sit behind NAT on
  # whatever wifi they are on, so the tailnet is the only stable route.
  #
  # The node identity is /var/lib/tailscale/tailscaled.state, not the ssh host
  # keys and not the hostname. It has to survive anything that rewrites the
  # machine, which for the Arch to NixOS transition meant listing that path in
  # /etc/NIXOS_LUSTRATE: without it the host comes back as a new node wanting a
  # browser login that nobody at the far end of the tailnet can give it.
  services.tailscale.enable = true;
}
