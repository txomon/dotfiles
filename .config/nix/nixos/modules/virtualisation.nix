{ pkgs, ... }: {
  # The daemon and its socket. The docker CLI comes from the home-manager side
  # (programs.txomon-docker), so it is not added here.
  virtualisation.docker.enable = true;

  # libvirtd plus the qemu stack behind it. Creates the `libvirtd` group, which
  # the polkit rule the module installs checks before allowing access to the
  # system URI.
  virtualisation.libvirtd.enable = true;

  # virt-install and virt-manager ship in the same package.
  environment.systemPackages = [ pkgs.virt-manager ];
}
