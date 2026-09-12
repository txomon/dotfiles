{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/thinkpad-x1-carbon-7th-gen
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
