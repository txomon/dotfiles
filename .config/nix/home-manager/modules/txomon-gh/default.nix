{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.txomon-gh;
in
{
  # home-manager owns programs.gh, and enabling that module writes a
  # ~/.config/gh/config.yml and registers a git credential helper on top of
  # installing the binary. Arch installed the binary and nothing else, so this
  # takes the txomon- prefix the repo already uses for txomon-git rather than
  # inherit configuration nobody asked for.
  options.programs.txomon-gh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "GitHub CLI, the binary with no configuration";
    };

    package = lib.mkPackageOption pkgs "gh" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
