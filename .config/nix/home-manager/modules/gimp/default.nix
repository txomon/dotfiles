{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gimp;
in
{
  options.programs.gimp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GIMP image editor";
    };

    package = lib.mkPackageOption pkgs "gimp" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
