{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.transmission_4-gtk;
in
{
  options.programs.transmission_4-gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Transmission BitTorrent client, GTK front end";
    };

    # transmission-gtk is a throw; 3 was dropped and 4 is a separate attribute.
    # Arch already ships 4.1.3, which is what this resolves to, so no data migration.
    package = lib.mkPackageOption pkgs "transmission_4-gtk" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
