{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.txomon-android = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set custom helpers for android";
    };
  };

  config = lib.mkIf config.programs.txomon-android.enable {
    home.packages = [
      (pkgs.writers.writePython3Bin "android-apk" { doCheck = false; } ./android-apk.py)
    ];
  };
}