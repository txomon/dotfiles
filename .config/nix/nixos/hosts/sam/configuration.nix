{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/thinkpad-x1-carbon-7th-gen
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For the Arch to NixOS transition only. NIXOS_LUSTRATE is implemented in
  # exactly one file in nixpkgs, nixos/modules/system/boot/stage-1-init.sh, the
  # scripted initrd. The systemd initrd, which is the default, has no lustrate
  # code, so the marker is ignored, Arch is never moved to /old-root, and the
  # activation runs against the live Arch root: 81 /etc paths replaced with no
  # backup and /lib64/ld-linux-x86-64.so.2 pointed at NixOS's stub, which kills
  # every Arch binary including init. Rehearsed twice in vm-lustrate, run A.
  #
  # Remove this line after the first NixOS boot. The marker lives in /etc and
  # /etc is what gets moved, so it destroys itself and there is no second
  # lustrate to guard against. Verified in vm-lustrate run D: flipping back is
  # a clean switch, and the deprecation warning disappearing is the signal that
  # the transition is finished.
  boot.initrd.systemd.enable = false;

  # Also for the transition, and also temporary. The lustrate rewrites
  # /etc/shadow, so javier comes back locked: `passwd -S javier` reports L and
  # GDM shows a bare username field with no account. An empty root password is
  # the documented way back in, and it only applies at account creation, so it
  # is inert once shadow exists. First boot: log in as root on tty1, run
  # `passwd javier`, then `passwd -l root`, then delete this line.
  users.users.root.initialHashedPassword = "";

  # sam's static hostname is bare "sam", with no domain, unlike pippin and
  # rosita which are both under endor.txomon.com. Left as found.

  # ThinkPad X1 Carbon 7th Gen, 20QDS0E700, i7-8565U (Whiskey Lake-U), BIOS
  # N2HET30W. This is the machine the lenovo-x1-carbon write-up was produced
  # on. The nixos-hardware module is added in flake.nix; the fingerprint reader
  # and the 4G modem come from the shared module imported above.

  # sam is the only host with an X11 variant set; `localectl` reports layout us,
  # variant altgr-intl.
  services.xserver.xkb.variant = "altgr-intl";

  system.stateVersion = "26.11";
}
