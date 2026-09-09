{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-claude = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Claude Code, plus csr for rotating its credentials";
    };
  };

  config = lib.mkIf config.programs.txomon-claude.enable {
    home.packages = [
      pkgs.claude-code

      # csr rotates ~/.claude/.credentials.json between saved profiles, so it
      # is only meaningful alongside Claude Code. See ./README.md.
      (pkgs.writeShellApplication {
        name = "csr";
        runtimeInputs = [
          pkgs.jq
          pkgs.util-linux # flock
        ];
        text = builtins.readFile ./csr.sh;
      })
    ];
  };
}
