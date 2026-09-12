# Vanta compliance agent, system side.
#
# The home-manager module at .config/nix/home-manager/modules/vanta-agent
# installs the binaries and says so: the daemon is root-owned and does not
# belong in a user profile. Its default.nix spells out the four things the
# system layer owes it, and all four are below.
#
# Off by default, and this is the one thing that stops it being on: the agent
# will not run without /etc/vanta.conf, which holds the Vanta agent key. This
# repo is public, so the key cannot live here and neither can a file that
# embeds it. See the option description for how to turn it on.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.vanta-agent;
in
{
  options.services.vanta-agent = {
    enable = lib.mkEnableOption ''
      the Vanta monitoring daemon.

      Provision /etc/vanta.conf first, root:root mode 0600, holding the agent
      key. The deb's postinst writes it as:

        {"ACTIVATION_REQUESTED_NONCE":<epoch ms>,"AGENT_KEY":"...",
         "OWNER_EMAIL":"...","REGION":"US","NEEDS_OWNER":true}

      That is a secret, so it wants sops-nix or agenix rather than
      environment.etc with a literal. Neither is a flake input yet, so for now
      it is placed on the machine out of band, the same way the user password
      is. With this on and that file missing, the unit restarts forever
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../home-manager/modules/vanta-agent/package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../home-manager/modules/vanta-agent/package.nix { }";
      description = "The vanta-agent build the state directory is seeded from.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. State, not a store symlink: the path is compiled into metalauncher and
    # launcher, and the metalauncher TUF-verifies and replaces the binaries
    # under it in place.
    systemd.tmpfiles.rules = [ "d /var/vanta 0755 root root -" ];

    # 2. Upstream's unit with the AUR drop-in folded in. A copy of the original
    # is at ${cfg.package}/share/doc/vanta/vanta.service for comparison.
    systemd.services.vanta-agent = {
      description = "Vanta monitoring software";
      after = [ "network.target" "syslog.target" ];
      wantedBy = [ "multi-user.target" ];

      # Seed once and then leave it alone, so a rebuild never clobbers a
      # binary the agent has updated itself to.
      preStart = ''
        for f in launcher metalauncher osquery-vanta.ext osqueryd; do
          [ -e /var/vanta/$f ] || install -m 0755 \
            ${cfg.package}/libexec/vanta/$f /var/vanta/$f
        done
        [ -e /var/vanta/cert.pem ] || install -m 0644 \
          ${cfg.package}/libexec/vanta/cert.pem /var/vanta/cert.pem
      '';

      serviceConfig = {
        # The /var/vanta copy on purpose, not the store path: the agent updates
        # itself, and a store ExecStart would be reverted on the next rebuild.
        ExecStart = "/var/vanta/metalauncher";
        TimeoutStartSec = 0;
        # Restart and RuntimeMaxSec are the AUR drop-in: the agent hangs often
        # enough to want a daily kick.
        Restart = "always";
        RuntimeMaxSec = "12h";
        KillMode = "control-group";
        KillSignal = "SIGTERM";
      };
    };

    # 3. vanta-cli reads /var/vanta, so it is only useful as root on a host
    # where the daemon is up. Installed system-wide rather than into javier's
    # profile for that reason.
    environment.systemPackages = [ cfg.package ];

    # 4. The self-update problem. autoPatchelfHook points the seeded osqueryd at
    # the store glibc, but the replacement metalauncher fetches over TUF carries
    # the interpreter Vanta ships, /lib64/ld-linux-x86-64.so.2, which NixOS does
    # not have. Without this the agent works until its first osquery update and
    # then stops. nix-ld provides that interpreter path.
    #
    # Untested against a running agent, as the home-manager module says: this is
    # the documented fix, not a verified one. An FHS wrapper around ExecStart is
    # the other way if it turns out not to be enough.
    programs.nix-ld.enable = true;
  };
}
