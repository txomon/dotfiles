{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.logseq;
in
{
  options.programs.logseq = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Logseq outliner";
    };

    package = lib.mkPackageOption pkgs "logseq" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
