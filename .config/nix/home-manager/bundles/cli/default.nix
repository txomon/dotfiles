{ config
, lib
, ...
}: {
  options.bundles.cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Terminal tools every host gets";
    };
  };

  config = lib.mkIf config.bundles.cli.enable {
    programs = {
      # home-manager's own module, which with no settings set installs the
      # binary and writes nothing. gh and codex have upstream modules too, but
      # theirs generate configuration, so those two are repo modules instead.
      btop.enable = true;
      imapsync.enable = true;
      nvtop.enable = true;
      piper-tts.enable = true;
      sox.enable = true;
      txomon-codex.enable = true;
      txomon-gh.enable = true;
      yq.enable = true;

      # computer-use-linux is packaged in modules/computer-use-linux but no
      # host enables it yet.
    };
  };
}
