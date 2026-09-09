{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.txomon-docker = {
      enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set custom helpers for docker";
      };
  };
  config = lib.mkIf config.programs.txomon-docker.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "docker-find-image-by-overlay" (builtins.readFile ./docker-find-image-by-overlay.sh))
    ];
  };
}