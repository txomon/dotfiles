{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.nvtop;
in
{
  options.programs.nvtop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GPU process monitor";
    };

    # The per-vendor variants only build one backend. This machine has both
    # Intel and NVIDIA graphics, so it needs the combined one.
    package = lib.mkPackageOption pkgs [ "nvtopPackages" "full" ] { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
