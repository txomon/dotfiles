{ config
, lib
, pkgs
, ...
}: {
  options.fleet-control.nix-cache = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Push home-manager and NixOS closures to the attic binary cache on gandalf";
    };
  };

  config = lib.mkIf config.fleet-control.nix-cache.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "nix-cache";
        # nix is deliberately not a runtimeInput. runtimeInputs are prepended to
        # PATH, and pkgs.nix (2.34.8) would shadow the system nix (2.35.2) that
        # owns the daemon this talks to.
        runtimeInputs = [ pkgs.attic-client pkgs.jq ];
        text = ''
          flake="''${1:-.}"

          # The flake root is not addressable as an attribute path, so this is
          # the only way to learn which output sets exist. It lists the
          # top-level names without recursing into them, in ~50ms.
          sets_raw="$(nix flake show --json "$flake" | jq -r 'keys[]')"
          mapfile -t sets <<< "$sets_raw"

          installables=()
          for outputs_set in "''${sets[@]}"; do
            case "$outputs_set" in
              homeConfigurations) attr="activationPackage" ;;
              nixosConfigurations) attr="config.system.build.toplevel" ;;
              *) continue ;;
            esac

            # attrNames does not force the configurations, so this stays in the
            # tens of milliseconds even though evaluating one of them does not.
            names_raw="$(nix eval --raw "$flake#$outputs_set" \
              --apply 'c: builtins.concatStringsSep "\n" (builtins.attrNames c)')"
            # An output set that exists but is empty is legitimate, not an error.
            [[ -n "$names_raw" ]] || continue
            mapfile -t names <<< "$names_raw"

            for name in "''${names[@]}"; do
              installables+=("$flake#$outputs_set.\"$name\".$attr")
            done
          done

          if [[ ''${#installables[@]} -eq 0 ]]; then
            echo "nix-cache: $flake has no homeConfigurations or nixosConfigurations" >&2
            exit 1
          fi

          # Build every configuration, then push them in a single attic session
          # so it deduplicates across all the closures at once.
          paths_raw="$(nix build --no-link --print-out-paths "''${installables[@]}")"
          mapfile -t paths <<< "$paths_raw"

          attic push homelab "''${paths[@]}"
        '';
      })
    ];
  };
}
