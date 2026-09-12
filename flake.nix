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
    # Decrypts the per-host sops file found by secrets.searchPaths.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , hm
    , fenix
    , nixos-hardware
    , sops-nix
    , ...
    }: {
      # `nix flake check` evaluates nixosConfigurations but does not build
      # them, so these are the outputs that actually prove anything. Each one
      # boots that host's own configuration.nix in a headless VM and asserts
      # against the running system. Note what they do not cover: the
      # nixos-hardware module below is added here rather than in
      # configuration.nix, so the test nodes never see it. Run all three with
      # `nix flake check`, or one with
      #   nix build .#checks.x86_64-linux.rosita-boots
      checks.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          # Passed in rather than imported by the tests, for the same reason
          # mkHost below passes it: a test node imports only the host's
          # configuration.nix, and modules/sops.nix sets options that do not
          # exist without this.
          sopsModule = sops-nix.nixosModules.sops;
          mkTest = { hostname, thinkpad }: pkgs.testers.runNixOSTest (
            import ./.config/nix/nixos/tests/system-boots.nix {
              inherit hostname thinkpad sopsModule;
            }
          );
        in
        {
          pippin-boots = mkTest { hostname = "pippin"; thinkpad = false; };
          rosita-boots = mkTest { hostname = "rosita"; thinkpad = true; };
          sam-boots = mkTest { hostname = "sam"; thinkpad = true; };

          # The one check that proves a secret arrives, rather than that the
          # config mentioning it evaluates.
          vanta-secret = pkgs.testers.runNixOSTest (
            import ./.config/nix/nixos/tests/vanta-secret.nix {
              hostname = "pippin";
              inherit sopsModule;
            }
          );
        };

      nixosConfigurations =
        let
          # No `system` or `pkgs` argument to nixosSystem: both are legacy
          # aliases for the nixpkgs.hostPlatform and nixpkgs.pkgs module
          # options. hostPlatform is set by each host's
          # hardware-configuration.nix, where nixos-generate-config puts it and
          # where a host on a different architecture could override it; the rest
          # of nixpkgs.config lives in .config/nix/nixos/modules/nix.nix.
          mkHost = { hostname, hardware ? [ ] }: nixpkgs.lib.nixosSystem {
            modules = hardware ++ [
              # Defines the sops.* options that .config/nix/nixos/modules/
              # sops.nix sets. Here rather than in that file so the module
              # tree stays free of flake inputs, the same as nixos-hardware.
              sops-nix.nixosModules.sops

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
          # rosita and sam are both ThinkPad X1 Carbon 7th Gen, so they get the
          # same model module. The fingerprint reader and 4G modem work they
          # also share is a repo module, imported by both host files.
          rosita = mkHost {
            hostname = "rosita";
            hardware = [ nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen ];
          };
          sam = mkHost {
            hostname = "sam";
            hardware = [ nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen ];
          };
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
