{
  description = "txomon's config files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs ships stable rustc only, and ringboard needs nightly.
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Per-model NixOS modules. pippin uses framework-13th-gen-intel.
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , hm
    , fenix
    , nixos-hardware
    , ...
    }: {
      nixosConfigurations =
        let
          # `system` and `pkgs` as arguments to nixosSystem are legacy aliases
          # for the nixpkgs.hostPlatform and nixpkgs.pkgs module options, so the
          # platform is set as a module instead. allowUnfree, the insecure
          # package allowance and the rest of nixpkgs.config live in
          # .config/nix/nixos/modules/nix.nix.
          mkHost = { hostname, hardware ? [ ] }: nixpkgs.lib.nixosSystem {
            modules = hardware ++ [
              { nixpkgs.hostPlatform = "x86_64-linux"; }
              ./.config/nix/nixos/hosts/${hostname}/configuration.nix

              # home-manager is deliberately NOT wired in as a NixOS submodule.
              # javier's home config stays standalone, driven by
              # `home-manager switch --flake .#javier@<host>`, so the two halves
              # can be rolled forward independently. To switch, add
              # `hm.nixosModules.home-manager` to this list and follow it with
              #   {
              #     home-manager.useGlobalPkgs = true;
              #     home-manager.useUserPackages = true;
              #     home-manager.users.javier =
              #       ./.config/nix/home-manager/hosts/${hostname}/javier.nix;
              #     home-manager.extraSpecialArgs = { inherit hostname; system = "x86_64-linux"; };
              #   }
              # and drop the homeConfigurations entry for that host.
            ];
            # No `system` here. The home side passes one because
            # homeManagerConfiguration has nowhere else to put it; on the NixOS
            # side nixpkgs.hostPlatform above is the single source of truth, and
            # a second copy in specialArgs would be one more thing to keep in
            # sync.
            specialArgs = { inherit hostname; };
          };
        in
        {
          pippin = mkHost {
            hostname = "pippin";
            hardware = [ nixos-hardware.nixosModules.framework-13th-gen-intel ];
          };
          # No nixos-hardware module for these two: neither machine has been
          # inspected, so there is nothing to justify a model claim.
          rosita = mkHost { hostname = "rosita"; };
          sam = mkHost { hostname = "sam"; };
        };

      homeConfigurations =
        let
          mkHost = hostname: hm.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = [ fenix.overlays.default ];
              config = {
                allowUnfree = true;
                # logseq is stuck on an Electron that upstream no longer
                # supports. Accepted knowingly rather than dropping the app.
                permittedInsecurePackages = [ "electron-39.8.10" ];
              };
            };
            modules = [ ./.config/nix/home-manager/hosts/${hostname}/javier.nix ];
            extraSpecialArgs = {
              inherit hostname;
              system = "x86_64-linux";
            };
          };
        in
        {
          "javier@pippin" = mkHost "pippin";
          "javier@rosita" = mkHost "rosita";
          "javier@sam" = mkHost "sam";
        };
    };
}
