{ config
, lib
, pkgs
, ...
}: {
  options.fleet-control.atm10 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Admin scripts for the ATM10 minecraft server on gandalf";
    };
  };

  config = lib.mkIf config.fleet-control.atm10.enable {
    home.packages = [
      # The server runs online-mode=false, so `/whitelist add` stores the
      # wrong UUID. This computes the offline one and writes it directly.
      (pkgs.symlinkJoin {
        name = "atm10-whitelist-add";
        paths = [
          (pkgs.writers.writePython3Bin "atm10-whitelist-add"
            {
              flakeIgnore = [ "E501" ];
            }
            (builtins.readFile ./whitelist-add.py))
        ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/atm10-whitelist-add \
            --prefix PATH : ${lib.makeBinPath [pkgs.openssh]}
        '';
      })

      (pkgs.writeShellApplication {
        name = "atm10-rcon";
        runtimeInputs = [ pkgs.openssh ];
        text = ''
          exec ssh -t gandalf 'podman exec -it all-the-mods-10 rcon-cli' "$@"
        '';
      })
    ];
  };
}
