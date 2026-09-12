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
      # Already in the closure as a runtimeInput of xcc and xcp below, but
      # those wrappers put it on PATH under their own names only. This is the
      # one that makes `xclip` itself callable, and it belongs next to its
      # wrappers rather than in a generic list.
      pkgs.xclip

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
