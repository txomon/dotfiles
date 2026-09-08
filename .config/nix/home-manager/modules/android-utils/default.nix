{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.android-utils = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set custom helpers for android";
    };
  };

  config = lib.mkIf config.programs.android-utils.enable {
    home.packages = [
      (pkgs.writers.writePython3Bin "android-apk" { doCheck = false; } ./android-apk.py)
    ];
  };
}