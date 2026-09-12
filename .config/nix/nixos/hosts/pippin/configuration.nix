{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
    # Work laptop. Vanta is not on rosita or sam, and neither is the
    # secret it needs.
    ../../modules/vanta.nix
  ];

  # EFI, matching the current install: /boot/EFI/systemd and /boot/loader are
  # already there, and /boot is the ESP.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.domain = "endor.txomon.com";

  # Framework Laptop 13, 13th Gen Intel (sys_vendor "Framework", product_name
  # "Laptop (13th Gen Intel Core)"). The nixos-hardware module is added in
  # flake.nix; it sets the fan/thermal, firmware and suspend tweaks.

  # Hybrid graphics: Intel Iris Xe at PCI 00:02.0 plus a GeForce GTX 1060 6GB
  # (GP106) on the Thunderbolt bus at PCI 82:00.0.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # nvidiaPackages.stable is 595, which dropped Maxwell, Pascal and Volta.
    # The 1060 is Pascal, so it needs the 580 LTSB branch.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # No default since 560: it has to be stated. Pascal is not supported by the
    # open kernel modules, so this stays on the proprietary ones.
    open = false;

    modesetting.enable = true;

    # hardware.nvidia.nvidiaSettings already defaults to true, which is where
    # nvidia-settings comes from. It is not a systemPackages entry.

    # Off deliberately: the suspend/resume hooks save VRAM to disk for a card
    # that may have been unplugged while asleep.
    powerManagement.enable = false;

    # Puts `Option "AllowExternalGpus"` in the X11 device section. Without it
    # the driver refuses to drive a GPU it sees on a Thunderbolt bus, which is
    # where this one lives. No effect on the Wayland session, which is GNOME's
    # default, but it makes the X11 fallback usable.
    prime.allowExternalGpu = true;
  };

  # PRIME render offload is left off. It needs a fixed nvidiaBusId, and this
  # card is an eGPU that comes and goes, so a hardcoded bus would be wrong half
  # the time. The IDs, in the decimal form the option wants, are:
  #
  #   hardware.nvidia.prime = {
  #     offload = { enable = true; enableOffloadCmd = true; };
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:130:0:0";
  #   };

  system.stateVersion = "26.11";
}
