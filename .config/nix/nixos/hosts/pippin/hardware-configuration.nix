# Generated on pippin with `nixos-generate-config --show-hardware-config` from
# pkgs.nixos-install-tools, checked against lsblk/blkid, run through
# nixpkgs-fmt, and extended with the boot.initrd.luks.devices entry the
# generator does not emit. Regenerating it drops that entry again.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # nvme0n1p2 is a LUKS2 container holding the LVM PV, so the volume group does
  # not exist until it is unlocked. Without this the initrd never finds
  # /dev/mapper/vg-root and the machine drops to an emergency shell.
  #
  # UUID from `blkid` / /dev/disk/by-uuid; "cryptlvm" is the mapper name the
  # current Arch install already uses (rd.luks.name=...=cryptlvm on /proc/cmdline).
  boot.initrd.luks.devices."cryptlvm" = {
    device = "/dev/disk/by-uuid/5291f69f-159e-43b3-b0b6-ba7ab55f467a";
    # allowDiscards is left off to match the Arch setup, which passes no
    # discard option. Turning it on leaks used-block counts to the SSD.
  };

  fileSystems."/" = {
    device = "/dev/mapper/vg-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2734-6CA4";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/mapper/vg-swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
