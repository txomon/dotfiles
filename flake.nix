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
  };

  outputs =
    { self
    , nixpkgs
    , hm
    , fenix
    , ...
    }: {
      homeConfigurations =
        let
          mkHost = hostname: hm.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = [ fenix.overlays.default ];
              config.allowUnfree = true;
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
