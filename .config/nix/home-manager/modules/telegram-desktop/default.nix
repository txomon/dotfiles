{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.telegram-desktop;
in
{
  options.programs.telegram-desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Telegram desktop client. The binary is `Telegram`.";
    };

    package = lib.mkPackageOption pkgs "telegram-desktop" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
