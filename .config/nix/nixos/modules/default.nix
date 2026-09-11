{ ... }: {
  imports = [
    ./desktop.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./peripherals.nix
    ./programs.nix
    ./users.nix
    ./vanta.nix
    ./virtualisation.nix
  ];
}
