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
      # The client only. The daemon is a system service and belongs in
      # virtualisation.docker on the NixOS side, not in a user profile.
      pkgs.docker-client
      # docker-client's wrapper already puts this exact store path on
      # DOCKER_CLI_PLUGIN_DIRS, so `docker compose` works without it. It is
      # listed for the standalone `docker-compose` name, which Arch also had.
      pkgs.docker-compose
      # Ships docker-credential-secretservice, which the credHelpers entry
      # below names, and docker-credential-pass.
      pkgs.docker-credential-helpers

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
