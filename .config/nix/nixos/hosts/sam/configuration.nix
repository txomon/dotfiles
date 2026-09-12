{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/thinkpad-x1-carbon-7th-gen
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # sam's ESP is 197M, against 1G on pippin and rosita, and one generation is
  # 46M of kernel plus initrd. Left unset, nixos-rebuild keeps an entry for
  # every generation and the fourth switch fails at bootloader install with no
  # space left. Three fits in 138M and leaves room for an initrd that grows.
  # The generations themselves are not deleted by this, only their boot
  # entries; `nix-collect-garbage` is still what removes them.
  boot.loader.systemd-boot.configurationLimit = 3;

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

  # The lustrate rewrites /etc/shadow, so both accounts would come back locked
  # and GDM would show a bare username field. Rather than an empty root
  # password, sam keeps the hashes it already has: they were copied out of its
  # own /etc/shadow into /var/lib/nixos-passwd, root-only, mode 0600, and both
  # paths are listed as keepers in /etc/NIXOS_LUSTRATE so stage 1 restores them
  # before activation reads them.
  #
  # hashedPasswordFile rather than hashedPassword: the file is read at
  # activation and never enters the world-readable store, which is the same
  # reason every *File option in nixpkgs exists. Nothing secret is in this repo.
  users.users.root.hashedPasswordFile = "/var/lib/nixos-passwd/root";
  users.users.javier.hashedPasswordFile = "/var/lib/nixos-passwd/javier";

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
