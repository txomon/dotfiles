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

    # Pinned rather than allocated. NixOS hands out the first free uid from
    # 1000 up and remembers the choice in /var/lib/nixos/uid-map, which on a
    # machine converted from Arch does not exist yet: a lustrate moves /var to
    # /old-root, so the allocator starts from scratch on the first boot. It
    # would almost certainly pick 1000 again, being the only normal user, and
    # "almost certainly" is not good enough when every file under /home/javier
    # carries the numeric id and the machine is remote. All three hosts are
    # 1000 today.
    uid = 1000;
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
    # No hashedPassword: public repo. Public keys are a different matter, they
    # are public by definition, so they live here rather than in a secret.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC9TLd4ymjC03GBfhPTvG+afvAqqFRg6eb0fJ72ZN6tZXWnmmp3oDFcaKH98JAjNBbopy4ZfYIWYaWXpmEjGSTAlDgRTVIl06jzyHCnnP2mK5awlp7dsN2kJZUc+nqxcvk7VfwhxDqQkYVBH+57Lo629kFhxtb9UsMWm9le9/v63klKUplJuNPxahWW43di+rENlZGsNMq3JhLQVqu6fugMnPaTvHukM04gDHZV9eZkpH1VURhA/jTmxu0wcTXmDhIAJo/wmpqx3dwUX9m5z0ndtuVErioaDJNTYzftasqdbInpdMMCHdJULQJZy3O/2nYxBQYu6u1cNarROrr9bWLQU56P2LAefhfF7DZOARSW9R1pSKFrG3nI7rYZejjo30myiJY79Z3KY8l1dgGZCd8s/O5PevVZFmaW8Jn8tcyFj9NCKDTmMisf5wHAxm3V+XNx08vYMEDkpncaFFhvU18yFsIrr9IMb01sGO7tgG9S1G8VKoAw8G1i4zISaY7jvkpzogm5wUM98tDRj0/M4/ApLABbP8CpxlAWh4BAXbDQC7cQ16TvjPoGskS5MLwV56zUZQvEnIbzN6ZjYrlyoq9W3az8rwfAeB1Abs8lvNKc82bLaJr1Y2hErTsBxh2TpZw6JHlNwWqeOZlp2c2+wI8NwMmtgkp6tezej8hW3W4xZnK0vdqZSsvH6yN+r13DZzCRnP/NHHMMh880SKkcxZ04agpikS34gku5OxnOSpAW7bu9aVXlWcZ6G78mbzdva+lkzZKyAqAh7/dNJ1QSkzXS7Al/qHA9EM0K+fl3HkShyB5Nm1/0S0oo928+/U5jSYV53vCztH05iaV2uEuq+psVpmqqmAwIoS96eZGeCZQiejOj970m2ZsETBWvXfUUQCy91bcwPgYfLcXp73/etjOT1nuDlTqR6GgO7AHnGUqQef+m6Kc+M0sKoJSu8uKyEhpJyM4X3qf/YRsf4SYhFcb9MVj+5sTDGiitKCUGYdAez0W8/4DJdx38Es0nGdhPblGpleLivAifyOr28Cksnx9Js8jYTlkI1WUShpbBEqGZKQZvbGgeyOwGxKiJA6NgxXro+cpKAnzDi7mmLCEQ8GdHtXi15wH84LX1nbJflMvPrBLYK9/eVZTv7GpQXDg59fbSvd6knVX/Pyoq2dH+E0nJLI7dQNHEYQ2gmT4ctan2Taxaq8hB2elGF8vtfO1w4q8qTaXMVwigFqFM2HQ7o5PmMD3yW0NxkNhQ/Icn2tpDqS4jPAFmUpMY2YFIdb4HzzsHuSy94tmDcrZZvwB800Fgh7yEKB/k8/Ilv8uovFMBqmeFw3uzzar0ZlU3gAL0wzoQagWaO/LHuCdKJMr/v8VN javier@rosita"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYKfoIAenCv9VbZFmN2yXlWGVt/LYvG7vEij/5ZMQ49Sg3OG5JUrNtO9gkPxMBxnDt6iq5Z0TqQmT6ogH7I5XDXALtdGZXm62KH2pIMsZj5SvvmKT3hhj3l/BpgqJXbXQt7GOnGcN13BVs4iGJPhBoILaYxjqWrnzKM0O0k23h1ye48JzDsAfRyvh7bpgf6rzMoCzfhCsvPjmhZD4/ghuwN5Ss76cPTvQt2PUWg4iJo1vRlVfKP6MWFON6rcON6x0o74+tRTr7Bg9+5cc2G/ZxxsMJyo2G6WbQoFVIw0pjbEx9eCW+iSIOcNPpDhiNz/0dhLOJ+P3zOhLb2AAVCgK/ /home/javier/.ssh/id_rsa"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGmyM7PO+GEyHusUXkXv+Ruxkgw/txy8TGBxPhS1wlD javier@pippin"
    ];
  };

  # What Arch already does here: /etc/sudoers on all three hosts carries
  # `%wheel ALL=(ALL) NOPASSWD: ALL`. NixOS defaults the other way, and on a
  # converted machine that is not a preference but a lockout: root ssh is off,
  # javier's password is whatever hash came out of the old /etc/shadow, and
  # nothing at the far end of the tailnet can type it. Setting it false
  # reproduces the behaviour the machines have now rather than widening it.
  security.sudo.wheelNeedsPassword = false;
}
