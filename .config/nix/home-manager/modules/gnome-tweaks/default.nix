{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gnome-tweaks;
in
{
  options.programs.gnome-tweaks = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GNOME Tweaks";
    };

    package = lib.mkPackageOption pkgs "gnome-tweaks" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
