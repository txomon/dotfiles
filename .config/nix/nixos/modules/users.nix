{ ... }: {
  # users.mutableUsers is left at its default (true). This repo is public, so no
  # password hash can live in it, and hashedPasswordFile would need a secret on
  # the machine before the first switch. mutableUsers true keeps every
  # credential out of git.
  #
  # The account is therefore created with no password, and a NixOS account with
  # no password cannot log in at GDM or on a TTY. On a fresh install, set one
  # before the first reboot: `nixos-install` asks for a root password, so log in
  # as root on tty1 and run `passwd javier`. Nothing here will do it for you.
  users.users.javier = {
    isNormalUser = true;
    description = "Javier Domingo Cansino";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # edit connections without a polkit prompt
      "docker" # talk to /run/docker.sock
      "wireshark" # use the setcap dumpcap wrapper
      "libvirtd" # manage VMs on the system URI
    ];
    # No adbusers: programs.adb was removed from nixpkgs and systemd 258 applies
    # the Android uaccess rules by itself.
    #
    # No openssh.authorizedKeys.keys and no hashedPassword: public repo.
  };
}
