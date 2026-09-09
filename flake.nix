{
  description = "txomon's config files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , hm
    , ...
    }: {
      homeConfigurations = {
        "javier@pippin" = hm.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ ];
            config.allowUnfree = true;
          };
          modules = [ ./.config/nix/home-manager/hosts/pippin/javier.nix ];
          extraSpecialArgs = {
            hostname = "pippin";
            system = "x86_64-linux";
          };
        };
      };
    };
}
