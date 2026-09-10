{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.gcloud;
in
{
  options.programs.gcloud = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The Google Cloud SDK";
    };

    extraComponents = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ]";
      description = ''
        Components folded into the SDK derivation. A component is a merge
        fragment, not a standalone package, so a module that needs one cannot
        install it itself and adds it here instead.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.google-cloud-sdk.withExtraComponents cfg.extraComponents) ];
  };
}
