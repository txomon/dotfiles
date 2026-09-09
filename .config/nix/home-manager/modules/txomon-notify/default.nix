{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-notify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "notify-send wrapper that defaults to a short \"Done!\"";
    };
  };

  config = lib.mkIf config.programs.txomon-notify.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "notify";
        runtimeInputs = [ pkgs.libnotify ];
        text = builtins.readFile ./notify.sh;
      })
    ];
  };
}
