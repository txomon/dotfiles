{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # Unverified: sam still runs Arch and was not reachable when this was written.
  # Confirm the firmware is EFI before switching; a BIOS machine needs
  # boot.loader.grub instead.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # No nixos-hardware module. pippin gets framework-13th-gen-intel because its
  # model was read off /sys/class/dmi/id. sam's is unknown, so nothing is
  # claimed; check github:NixOS/nixos-hardware for a matching module once the
  # machine can be inspected.

  # No hardware.nvidia or services.xserver.videoDrivers: the graphics hardware
  # has not been looked at.

  system.stateVersion = "26.11";
}
