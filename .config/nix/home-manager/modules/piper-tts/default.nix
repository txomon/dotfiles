{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.piper-tts;
in
{
  options.programs.piper-tts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Neural text to speech";
    };

    # Installs the binary as `piper`. Arch's piper-tts-bin called it
    # `piper-tts`, so anything invoking the old name needs updating.
    package = lib.mkPackageOption pkgs "piper-tts" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
