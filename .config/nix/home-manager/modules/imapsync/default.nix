{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.imapsync;
in
{
  options.programs.imapsync = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "IMAP mailbox copier";
    };

    package = lib.mkPackageOption pkgs "imapsync" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
