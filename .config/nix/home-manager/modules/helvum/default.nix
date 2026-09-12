{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.helvum;
in
{
  options.programs.helvum = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "PipeWire patchbay";
    };

    package = lib.mkPackageOption pkgs "helvum" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
