{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set custom helpers for git";
    };
  };
  config = lib.mkIf config.programs.txomon-git.enable {
    home.packages = [
      # Named git-* so git picks it up as `git file-size-diff`.
      (pkgs.writeShellScriptBin "git-file-size-diff" (builtins.readFile ./git-file-size-diff.sh))
    ];

    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        alias.last = "log --format=%H -n1";
        pull.ff = "only";
        push.autoSetupRemote = true;
        rerere.enabled = true;
      };

      ignores = [
        ".idea/"
        ".vscode/"
        "*.orig"
        "*.new"
        ".envrc"
        ""
        "**/.claude/settings.local.json"
      ];
    };
  };
}
