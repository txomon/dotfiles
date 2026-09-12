{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.spotify;
in
{
  options.programs.spotify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Spotify desktop client";
    };

    package = lib.mkPackageOption pkgs "spotify" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
