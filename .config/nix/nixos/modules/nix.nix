{ ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Same nixpkgs settings the homeConfigurations get. The home side builds its
  # own `pkgs` with an `import nixpkgs { config = { ... }; }`; on the NixOS
  # side the equivalent is the `nixpkgs.config` module option. Keep the two in
  # step: the insecure entry below is logseq's Electron, same as in flake.nix.
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-39.8.10" ];
  };

  # No overlays. The fenix overlay exists for ringboard, which is a
  # home-manager package, so nothing on the system side needs a nightly rustc.
  # If that changes, add it here as `nixpkgs.overlays = [ fenix.overlays.default ];`
  # and pass `fenix` through `specialArgs` in flake.nix.
}
