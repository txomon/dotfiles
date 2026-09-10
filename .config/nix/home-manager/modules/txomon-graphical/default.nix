{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-graphical = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Short wrappers for desktop things that need a display";
    };
  };

  config = lib.mkIf config.programs.txomon-graphical.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "open";
        runtimeInputs = [ pkgs.xdg-utils ];
        text = ''exec xdg-open "$@"'';
      })

      (pkgs.writeShellApplication {
        name = "xcc";
        runtimeInputs = [ pkgs.xclip ];
        text = ''exec xclip -selection clipboard "$@"'';
      })

      (pkgs.writeShellApplication {
        name = "xcp";
        runtimeInputs = [ pkgs.xclip ];
        text = ''exec xclip -selection primary "$@"'';
      })
    ];
  };
}
