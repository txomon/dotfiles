# Generated on rosita with `nixos-generate-config --show-hardware-config`,
# reformatted with nixpkgs-fmt, and extended with the boot.initrd.luks.devices
# entry the generator does not emit. Regenerating it drops that entry again.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # nvme0n1p2 is a LUKS2 container holding the LVM PV, so the volume group does
  # not exist until it is unlocked and nothing below resolves. The mapper name
  # is "root" here and "cryptroot" on sam; they are not interchangeable.
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/f05c40d0-9ff1-4d5e-a3a6-1c996064935a";
  };

  fileSystems."/" = {
    device = "/dev/mapper/vg-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/826D-05EA";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/mapper/vg-swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
