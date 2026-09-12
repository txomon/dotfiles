{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.xdotool;
in
{
  options.programs.xdotool = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "X11 input and window automation";
    };

    package = lib.mkPackageOption pkgs "xdotool" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
