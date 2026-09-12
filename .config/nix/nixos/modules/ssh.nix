{ ... }: {
  # Every machine in the fleet is reachable over tailscale and is administered
  # remotely, so sshd is not optional. It also mattered for the Arch to NixOS
  # transition: without it the migrated machine is console-only, and the
  # NetworkManager connections move to /old-root, so it would not even have a
  # route until someone reconnects the wifi at the keyboard.
  services.openssh = {
    enable = true;

    settings = {
      # Keys only. javier's are in users.nix; they are public by definition.
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # After a lustrate the old host keys are in /old-root/etc/ssh. Copy them back
  # before deleting it, or the machine changes identity: every known_hosts
  # entry starts warning and tailscale sees a different node. sam's were listed
  # as keepers in /etc/NIXOS_LUSTRATE and came through unchanged.
  #
  # These are also what sops-nix's age.sshKeyPaths defaults to, so a machine
  # with host keys can decrypt its own secrets without a separate age key.
}
