{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.theclicker;
in
{
  options.programs.theclicker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Autoclicker. Synthesises X11 clicks, so it needs a display.";
    };

    package = lib.mkPackageOption pkgs "theclicker" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
