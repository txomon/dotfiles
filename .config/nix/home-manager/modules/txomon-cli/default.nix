{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Terminal tools with no configuration of their own";
    };
  };

  config = lib.mkIf config.programs.txomon-cli.enable {
    home.packages = [
      pkgs.btop
      # The per-vendor variants only build one backend. This machine has both
      # Intel and NVIDIA graphics, so it needs the combined one.
      pkgs.nvtopPackages.full
    ];
  };
}
