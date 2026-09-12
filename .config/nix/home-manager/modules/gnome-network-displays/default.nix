{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gnome-network-displays;
in
{
  options.programs.gnome-network-displays = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Screen casting to Miracast and Chromecast receivers";
    };

    package = lib.mkPackageOption pkgs "gnome-network-displays" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
