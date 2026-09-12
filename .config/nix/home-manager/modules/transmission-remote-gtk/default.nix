{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.transmission-remote-gtk;
in
{
  options.programs.transmission-remote-gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GTK remote control for a transmission daemon";
    };

    package = lib.mkPackageOption pkgs "transmission-remote-gtk" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
