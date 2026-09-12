# Vanta compliance agent, system side.
#
# The home-manager module at .config/nix/home-manager/modules/vanta-agent
# installs the binaries and says so: the daemon is root-owned and does not
# belong in a user profile. Its default.nix spells out the four things the
# system layer owes it, and all four are below.
#
# Off by default. The agent will not run without /etc/vanta.conf, which holds
# the Vanta agent key; that file is now a sops secret out of this host's own
# encrypted file, so enabling this is the only step left once the key is in
# there. See the option description.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.vanta-agent;
in
{
  options.services.vanta-agent = {
    enable = lib.mkEnableOption ''
      the Vanta monitoring daemon.

      /etc/vanta.conf comes from the vanta_conf key of this host's sops file,
      so the only thing to do before turning this on is put the real agent key
      there:

        sops <secrets dir>/pippin.yaml

      README.md, under Secrets, says which directories are searched. The value
      is the JSON the deb's postinst writes, verbatim:

        {"ACTIVATION_REQUESTED_NONCE":<epoch ms>,"AGENT_KEY":"...",
         "OWNER_EMAIL":"...","REGION":"US","NEEDS_OWNER":true}

      That host also needs /var/lib/sops-nix/key.txt, or nothing can be
      decrypted. With this on and either of those missing, the daemon refuses
      to start and `systemctl status sops-install-secrets` says why
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../home-manager/modules/vanta-agent/package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../home-manager/modules/vanta-agent/package.nix { }";
      description = "The vanta-agent build the state directory is seeded from.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 0. The agent key. sops.defaultSopsFile is whatever the search in
    # ./sops.nix turned up for this host, so this only has to name the key
    # inside it. /etc/vanta.conf is a symlink to /run/secrets/vanta_conf,
    # itself a symlink into the current generation under /run/secrets.d. The
    # file at the end of that carries the root:root 0600, and /run/secrets.d
    # is a ramfs, so the plaintext never reaches a disk.
    sops.secrets.vanta_conf = {
      path = "/etc/vanta.conf";
      owner = "root";
      group = "root";
      mode = "0600";
      restartUnits = [ "vanta-agent.service" ];
    };

    # 1. State, not a store symlink: the path is compiled into metalauncher and
    # launcher, and the metalauncher TUF-verifies and replaces the binaries
    # under it in place.
    systemd.tmpfiles.rules = [ "d /var/vanta 0755 root root -" ];

    # 2. Upstream's unit with the AUR drop-in folded in. A copy of the original
    # is at ${cfg.package}/share/doc/vanta/vanta.service for comparison.
    systemd.services.vanta-agent = {
      description = "Vanta monitoring software";
      after = [ "network.target" "syslog.target" "sops-install-secrets.service" ];
      wantedBy = [ "multi-user.target" ];

      # Requires, not just after. /etc/vanta.conf is the one thing the agent
      # cannot start without, and the search for this host's sops file runs
      # inside sops-install-secrets.service. If that file is missing or cannot
      # be decrypted, that unit fails and this one refuses to start rather
      # than looping against a config that is not there. `systemctl status
      # sops-install-secrets` then names every directory that was searched.
      requires = [ "sops-install-secrets.service" ];

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
