{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gnome-power-manager;
in
{
  options.programs.gnome-power-manager = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GNOME power statistics";
    };

    package = lib.mkPackageOption pkgs "gnome-power-manager" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
