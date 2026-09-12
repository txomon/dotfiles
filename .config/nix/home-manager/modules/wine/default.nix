{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.wine;
in
{
  options.programs.wine = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Wine, 64-bit capable";
    };

    # pkgs.wine at 11.0 is built 32-bit only: lib/wine/ has i386-unix and
    # i386-windows and nothing else, so it cannot run an x64 Windows binary
    # or a win64 prefix. wineWow64Packages.stable is the same 11.0 with
    # x86_64-unix and x86_64-windows, which is what pCon.planner needs.
    package = lib.mkPackageOption pkgs [ "wineWow64Packages" "stable" ] { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
