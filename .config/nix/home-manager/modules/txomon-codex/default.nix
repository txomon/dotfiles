{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.txomon-codex;
in
{
  # Prefixed for the same reason as txomon-gh: home-manager owns
  # programs.codex, and its module generates a config file, a skills tree and
  # a plugin cache alongside the binary.
  options.programs.txomon-codex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Codex CLI, the binary with no configuration";
    };

    # 0.151.0 here against the 0.153.4 Arch was running, so this is a
    # downgrade of two patch releases until nixpkgs catches up.
    package = lib.mkPackageOption pkgs "codex" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
