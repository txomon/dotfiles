{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-egpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Unload the nvidia kernel modules before unplugging the eGPU";
    };
  };

  config = lib.mkIf config.programs.txomon-egpu.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "egpu";
        runtimeInputs = [ pkgs.kmod ];
        text = builtins.readFile ./egpu.sh;
      })
    ];
  };
}
