{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Terminal tools with no configuration of their own";
    };
  };

  config = lib.mkIf config.programs.txomon-cli.enable {
    home.packages = [
      pkgs.btop
      # 0.151.0 here against the 0.153.4 Arch was running, so this is a
      # downgrade of two patch releases until nixpkgs catches up.
      pkgs.codex
      pkgs.gh
      pkgs.imapsync
      # The per-vendor variants only build one backend. This machine has both
      # Intel and NVIDIA graphics, so it needs the combined one.
      pkgs.nvtopPackages.full
      # Installs the binary as `piper`. Arch's piper-tts-bin called it
      # `piper-tts`, so anything invoking the old name needs updating.
      pkgs.piper-tts
      # The original SoX, last released 14.4.2. Arch had moved to the sox_ng
      # fork at 14.8.0.1; nixpkgs has no such package.
      pkgs.sox
      # The python jq wrapper, which is what Arch's `yq` is, and which also
      # ships xq and tomlq. `pkgs.yq-go` is a different program with different
      # syntax. 3.4.3 against Arch's 4.1.2.
      pkgs.yq

      # computer-use-linux is not in nixpkgs. Add it here once it is packaged.
    ];
  };
}
