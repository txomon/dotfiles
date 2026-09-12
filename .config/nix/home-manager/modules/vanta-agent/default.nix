{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.vanta-agent;
in
{
  options.programs.vanta-agent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Vanta compliance monitoring agent";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The vanta-agent build to install.";
    };
  };

  # This module installs the binaries and nothing else. The daemon is a
  # root-owned system service and does not belong in a user profile, so the
  # NixOS layer has to declare it.
  #
  # What the system layer needs:
  #
  # 1. /var/vanta, root-owned, mode 0755, writable. The path is compiled into
  #    metalauncher and launcher; it is state, not a store symlink. The
  #    metalauncher TUF-verifies and replaces launcher, osqueryd and
  #    osquery-vanta.ext in place, so seed the directory from
  #    ${cfg.package}/libexec/vanta on first start and then leave it alone:
  #
  #      systemd.tmpfiles.rules = [ "d /var/vanta 0755 root root -" ];
  #
  #      systemd.services.vanta-agent.preStart = ''
  #        for f in launcher metalauncher osquery-vanta.ext osqueryd; do
  #          [ -e /var/vanta/$f ] || install -m 0755 \
  #            ${cfg.package}/libexec/vanta/$f /var/vanta/$f
  #        done
  #        [ -e /var/vanta/cert.pem ] || install -m 0644 \
  #          ${cfg.package}/libexec/vanta/cert.pem /var/vanta/cert.pem
  #      '';
  #
  # 2. The unit itself. Upstream's copy is kept at
  #    ${cfg.package}/share/doc/vanta/vanta.service for reference; this is it
  #    with the AUR drop-in folded in (Restart=always and RuntimeMaxSec=12h,
  #    because the agent hangs often enough to need a daily kick):
  #
  #      systemd.services.vanta-agent = {
  #        description = "Vanta monitoring software";
  #        after = [ "network.target" "syslog.target" ];
  #        wantedBy = [ "multi-user.target" ];
  #        serviceConfig = {
  #          ExecStart = "/var/vanta/metalauncher";
  #          TimeoutStartSec = 0;
  #          Restart = "always";
  #          RuntimeMaxSec = "12h";
  #          KillMode = "control-group";
  #          KillSignal = "SIGTERM";
  #        };
  #      };
  #
  #    ExecStart is the /var/vanta copy on purpose: the agent updates itself
  #    and a store path would be reverted on the next rebuild.
  #
  # 3. /etc/vanta.conf, root:root, mode 0600. Holds the agent key, so it is a
  #    sops-nix secret rather than a literal in the repo: the vanta_conf key
  #    of the host's own sops file, found by the search README.md describes.
  #    The format the deb's postinst writes, and what that key holds verbatim:
  #
  #      {"ACTIVATION_REQUESTED_NONCE":<epoch ms>,"AGENT_KEY":"...",
  #       "OWNER_EMAIL":"...","REGION":"US","NEEDS_OWNER":true}
  #
  # 4. Something for the self-updates to run against. The seeded osqueryd is
  #    the only dynamic binary in the package and autoPatchelfHook points it
  #    at the store glibc, but the copy metalauncher fetches over TUF to
  #    replace it will carry the interpreter Vanta ships it with,
  #    /lib64/ld-linux-x86-64.so.2, which NixOS does not have. So the agent
  #    works until its first osquery update and then stops. programs.nix-ld
  #    covers that; an FHS wrapper around ExecStart is the other way.
  #    Untested, on the grounds that running a monitoring agent to find out
  #    is not a packaging step.
  #
  # vanta-cli reads that state directory, so it only tells you anything useful
  # when run as root on a host where the daemon is up.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
