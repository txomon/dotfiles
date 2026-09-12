{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/thinkpad-x1-carbon-7th-gen
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.domain = "endor.txomon.com";

  # ThinkPad X1 Carbon 7th Gen, 20QDS37700, i7-8565U (Whiskey Lake-U), BIOS
  # N2HET46W. The nixos-hardware module is added in flake.nix; the fingerprint
  # reader and the 4G modem come from the shared module imported above.

  # Overrides the fleet default. rosita reports Atlantic/Canary, where pippin
  # and sam both report Europe/Madrid.
  time.timeZone = "Atlantic/Canary";

  system.stateVersion = "26.11";
}
