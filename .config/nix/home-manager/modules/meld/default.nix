{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.meld;
in
{
  options.programs.meld = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Meld diff and merge tool";
    };

    package = lib.mkPackageOption pkgs "meld" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
