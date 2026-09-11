{ ... }: {
  # users.mutableUsers is left at its default (true). This repo is public, so no
  # password hash can live in it, and hashedPasswordFile would need a secret on
  # the machine before the first switch. With mutableUsers true the account is
  # created without a password and `passwd` sets one out of band, which keeps
  # every credential out of git.
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
