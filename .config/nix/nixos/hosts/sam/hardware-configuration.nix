# Generated on sam with `nixos-generate-config --show-hardware-config`,
# reformatted with nixpkgs-fmt, and extended with the boot.initrd.luks.devices
# entry the generator does not emit. Regenerating it drops that entry again.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # nvme0n1p2 is a LUKS2 container holding the LVM PV, so the volume group does
  # not exist until it is unlocked and nothing below resolves. The mapper name
  # is "cryptroot" here and "root" on rosita; they are not interchangeable.
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/ddbe42e0-5c81-4823-94e1-775de11be58e";
  };

  fileSystems."/" = {
    device = "/dev/mapper/vg-root";
    fsType = "ext4";
  };

  # 200M ESP here, against 1G on rosita and pippin.
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/78E5-5A71";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/mapper/vg-swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
