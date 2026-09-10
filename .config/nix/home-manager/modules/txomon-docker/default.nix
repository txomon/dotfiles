{ config
, lib
, pkgs
, ...
}:
let
  # gcloud ships the `docker-credential-gcloud` helper, so the GCP registry
  # entries are only useful when the SDK is part of this configuration.
  gcloud-active = lib.any (p: lib.getName p == "google-cloud-sdk") config.home.packages;
in
{
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

    # Containers write into bind mounts as root, so the host copy comes back
    # owned by root. chj takes the tree back.
    xdg.configFile = lib.mkIf config.programs.elvish.enable {
      "elvish/rc.d/30-txomon-docker.elv".text = ''
        edit:add-var chj~ { sudo chown -R ${config.home.username}: . }
      '';
    };

    programs.docker-cli = {
      enable = true;
      settings = {
        auths."ghcr.io" = { };
        credHelpers = {
          "ghcr.io" = "secretservice";
        } // lib.optionalAttrs gcloud-active {
          "eu.gcr.io" = "gcloud";
          "europe-west1-docker.pkg.dev" = "gcloud";
          "gcr.io" = "gcloud";
          "marketplace.gcr.io" = "gcloud";
          "staging-k8s.gcr.io" = "gcloud";
          "us.gcr.io" = "gcloud";
        };
      };
    };
  };
}
