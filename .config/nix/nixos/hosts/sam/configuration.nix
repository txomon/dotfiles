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

  # The Arch to NixOS transition happened here on 2026-09-12 and both settings
  # it needed are now gone. boot.initrd.systemd.enable was false for exactly
  # one boot, because NIXOS_LUSTRATE is implemented only in the scripted
  # initrd; removing it puts the systemd initrd back, which is also what makes
  # the yubikey unlock the disk again, since systemd-cryptsetup is the only
  # side that reads the systemd-fido2 token in the LUKS2 header.
  #
  # users.users.<name>.hashedPasswordFile pointed at /var/lib/nixos-passwd,
  # holding the hashes copied out of Arch's /etc/shadow. With mutableUsers
  # true those files seed an account that is new to /etc/shadow and are
  # ignored afterwards, so they did their job on the first boot and leaving
  # them in would only mislead. See update-users-groups.pl, which applies
  # hashedPassword to an existing shadow line only when mutableUsers is false.

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
