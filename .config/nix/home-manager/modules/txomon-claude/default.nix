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

    # Claude Code repaints the whole screen on exit otherwise, wiping the
    # scrollback of whatever pane it ran in.
    home.sessionVariables.CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN = 1;

    xdg.configFile = lib.mkIf config.programs.elvish.enable {
      "elvish/rc.d/20-txomon-claude.elv".text = ''
        edit:add-var cs~ {|@a| claude --dangerously-skip-permissions $@a }
      '';
    };
  };
}
