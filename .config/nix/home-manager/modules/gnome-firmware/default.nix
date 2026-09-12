{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gnome-firmware;
in
{
  options.programs.gnome-firmware = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GNOME firmware updater";
    };

    package = lib.mkPackageOption pkgs "gnome-firmware" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
