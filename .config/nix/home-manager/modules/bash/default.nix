{ config
, lib
, ...
}:
let
  cfg = config.programs.bash;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash = {
      historyControl = [ "ignoreboth" ];
      historySize = 10000000;
      historyFileSize = 200000000;

      shellOptions = [
        # Append to the history file rather than replacing it.
        "histappend"

        # Recheck LINES and COLUMNS after every command.
        "checkwinsize"

        # Extended globbing, and ** across directories.
        "extglob"
        "globstar"
      ];

      initExtra = ''
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"

        # bash is only the login shell. The real environment is elvish, which
        # tmux starts as its default-shell, so hand over immediately.
        if [[ -z "$TMUX" ]]; then
          tmux new-session -A -s default
        fi
      '';
    };
  };
}
