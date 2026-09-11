{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.configuradorfnmt;
in
{
  options.programs.configuradorfnmt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "FNMT-RCM tool to request keys and certificates";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The configuradorfnmt build to install.";
    };
  };

  # The AUR package lists icedtea-web as an optional dependency, used only when
  # certificate renewal falls back to a JNLP applet. Nothing this package
  # installs calls it, so it is not packaged; if renewal ever needs it, it has
  # to come in as its own module.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
