{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.yq;
in
{
  options.programs.yq = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "jq wrapper for YAML, XML and TOML";
    };

    # The python jq wrapper, which is what Arch's `yq` is, and which also
    # ships xq and tomlq. `pkgs.yq-go` is a different program with different
    # syntax. 3.4.3 against Arch's 4.1.2.
    package = lib.mkPackageOption pkgs "yq" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
