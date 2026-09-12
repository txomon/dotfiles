{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.factorio;
in
{
  options.programs.factorio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Factorio";
    };

    package = lib.mkPackageOption pkgs "factorio" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
