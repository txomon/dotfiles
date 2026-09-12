{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gnome-browser-connector;
in
{
  options.programs.gnome-browser-connector = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Native host for the GNOME Shell browser extension";
    };

    package = lib.mkPackageOption pkgs "gnome-browser-connector" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
