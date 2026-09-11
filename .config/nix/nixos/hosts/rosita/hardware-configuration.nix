# THIS IS A PLACEHOLDER. It does not describe rosita.
#
# Nothing in here was read off the machine. The disk, the filesystem and the
# initrd modules are invented, so that the configuration evaluates and
# `config.system.build.toplevel` builds from another host.
#
# Replace it before installing anything, by running this ON rosita:
#
#   nixos-generate-config --show-hardware-config \
#     > .config/nix/nixos/hosts/rosita/hardware-configuration.nix
#
# and then checking the result against `lsblk -f`, in particular that every
# encrypted or LVM device the root filesystem sits behind has a
# boot.initrd.luks.devices entry. nixos-generate-config does not emit those.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/PLACEHOLDER-REPLACE-ME";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
