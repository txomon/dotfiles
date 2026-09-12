{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.pcon-planner;
in
{
  options.programs.pcon-planner = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Launcher for the existing pCon.planner 8.6 Wine prefix";
    };

    prefix = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/wineprefixes/pcon";
      description = ''
        Wine prefix holding the pCon.planner 8.6 installation. It is mutable
        state that predates this configuration and cannot be rebuilt, so it is
        referred to rather than managed, the way a Steam library is.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { inherit (cfg) prefix; };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { inherit (cfg) prefix; }";
      description = "The pCon.planner 8.6 launcher to install.";
    };
  };

  # 8.6 is kept rather than upgraded because EasternGraphics no longer serves its
  # installer, so a lost prefix cannot be recreated. programs.pcon-planner is the
  # separate, reproducible 8.15 package; the two can be installed side by side.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
