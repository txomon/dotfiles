{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.jadx;
in
{
  options.programs.jadx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Android dex to Java decompiler";
    };

    package = lib.mkPackageOption pkgs "jadx" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
