{ ... }: {
  imports = [
    ./desktop.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./peripherals.nix
    ./programs.nix
    ./ssh.nix
    ./sops.nix
    ./users.nix
    ./virtualisation.nix
  ];
}
