{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.sox;
in
{
  options.programs.sox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Sound eXchange audio converter";
    };

    # The original SoX, last released 14.4.2. Arch had moved to the sox_ng
    # fork at 14.8.0.1; nixpkgs has no such package.
    package = lib.mkPackageOption pkgs "sox" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
