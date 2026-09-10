{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.jetbrains;
in
{
  options.programs.jetbrains = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "JetBrains IDEs and the IdeaVim keymap they all share";
    };

    ides = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "goland" "idea" ];
      description = ''
        Attribute names under `pkgs.jetbrains`, one per IDE to install. A name
        that is not there fails evaluation with `attribute missing`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = map (name: pkgs.jetbrains.${name}) cfg.ides;

    # Every JetBrains IDE with the IdeaVim plugin reads this, so one file
    # covers all of them.
    home.file.".ideavimrc".source = ./ideavimrc;
  };
}
