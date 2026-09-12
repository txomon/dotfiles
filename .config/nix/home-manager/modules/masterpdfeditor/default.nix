{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.masterpdfeditor;
in
{
  options.programs.masterpdfeditor = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Master PDF Editor";
    };

    package = lib.mkOption {
      type = lib.types.package;
      # The pinned nixpkgs has 5.9.98, whose tarball code-industry has since
      # removed: the URL 404s. They only serve the current release. Bumped to
      # 5.9.99, which is the version Arch is running and the one nixpkgs master
      # already moved to. The qt5 build, not the qt6 one the AUR uses, because
      # the rest of the derivation autoPatchelfs against libsForQt5.
      default = pkgs.masterpdfeditor.overrideAttrs (final: prev: {
        version = "5.9.99";
        src = pkgs.fetchurl {
          url = "https://code-industry.net/public/master-pdf-editor-5.9.99-qt5.x86_64-qt_include.tar.gz";
          hash = "sha256-ksVuJyuImstESVwHUmOUv6aERosg6g5bSsRvPSf5EVM=";
        };
      });
      defaultText = lib.literalExpression "pkgs.masterpdfeditor.overrideAttrs { version = \"5.9.99\"; ... }";
      description = "The Master PDF Editor build to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
