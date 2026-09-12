{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.winetricks;
in
{
  options.programs.winetricks = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Helper scripts for wine prefixes";
    };

    package = lib.mkPackageOption pkgs "winetricks" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
