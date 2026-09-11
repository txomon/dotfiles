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
      description = "pCon.planner, EasternGraphics' CAD planner, under Wine";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The pCon.planner build to install.";
    };
  };

  # The package carries its own patched wine-staging rather than borrowing the
  # host's: the three fixes are builtin DLL patches, and shell32 in particular is
  # too central to override natively per prefix.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
