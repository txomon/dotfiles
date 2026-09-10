{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.slack;
in
{
  options.programs.slack = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Slack desktop client";
    };

    package = lib.mkPackageOption pkgs "slack" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
