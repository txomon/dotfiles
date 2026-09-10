{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.elvish;
in
{
  options.programs.elvish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        The interactive shell. bash is the login shell and only hands over to
        tmux, which starts elvish, so this is where the actual environment
        lives. home-manager has no elvish module, so the files are written
        directly.
      '';
    };

    package = lib.mkPackageOption pkgs "elvish" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      # Modules drop numbered fragments into rc.d; rc.elv loops over them.
      "elvish/rc.elv".text = builtins.replaceStrings
        [ "@rcd@" ]
        [ "${config.xdg.configHome}/elvish/rc.d" ]
        (builtins.readFile ./rc.elv);

      # direnv is installed by home-manager, so point the hook at that store
      # path rather than whatever `direnv` happens to be first on PATH.
      "elvish/lib/direnv.elv".text = builtins.replaceStrings
        [ "@direnv@" ]
        [ "${config.programs.direnv.package}/bin/direnv" ]
        (builtins.readFile ./lib/direnv.elv);
    };
  };
}
