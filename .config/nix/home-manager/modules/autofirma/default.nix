{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.autofirma;
in
{
  options.programs.autofirma = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Cliente @firma, the Spanish government's signature client";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The autofirma build to install.";
    };
  };

  # The Arch package also drops a pref file into /usr/lib/firefox/defaults/pref
  # to register the afirma: scheme handler. A Firefox built by nix only reads
  # prefs from its own store path, so that half belongs in
  # programs.firefox.profiles.<name>.settings, not here. The .desktop file's
  # MimeType line covers every browser that goes through xdg-open.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
