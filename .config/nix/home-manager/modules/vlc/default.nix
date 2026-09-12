{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.vlc;
in
{
  options.programs.vlc = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "VLC media player";
    };

    package = lib.mkPackageOption pkgs "vlc" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
