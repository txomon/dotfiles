# Where a host's secrets come from. The sops-nix module that defines the
# sops.* options is added in flake.nix, next to the nixos-hardware ones.
#
# Nothing here declares a secret. A module that needs one adds an entry to
# sops.secrets and gets this host's file for free; ./vanta.nix is the only one
# so far.
#
# The file is named by absolute path, never by a path literal, so nix does not
# read it and does not copy it into the world-readable store. The cost is that
# a missing file cannot be caught at evaluation time, so it is caught at
# service start instead. See sops.useSystemdActivation below.
{ config, hostname, lib, pkgs, ... }:

let
  cfg = config.secrets;

  # Where the search puts what it found. sops-nix is pointed at this rather
  # than at any of the search paths, because it takes one file and the search
  # takes a list.
  resolved = "/run/sops-source.yaml";

  search = pkgs.writeShellScript "resolve-host-secrets" ''
    set -eu

    for dir in ${lib.escapeShellArgs cfg.searchPaths}; do
      candidate="$dir/${hostname}.yaml"
      if [ -r "$candidate" ]; then
        ln -sfn "$candidate" ${resolved}
        echo "secrets for ${hostname}: $candidate"
        exit 0
      fi
    done

    rm -f ${resolved}
    echo "no secrets file for ${hostname}." >&2
    echo "Looked for ${hostname}.yaml, in order, in:" >&2
    ${lib.concatMapStringsSep "\n"
      (p: "echo ${lib.escapeShellArg "  ${p}"} >&2")
      cfg.searchPaths}
    echo "Put the file in one of those, or change secrets.searchPaths." >&2
    echo "README.md, under Secrets, has the rest." >&2
    exit 1
  '';
in
{
  options.secrets.searchPaths = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      # The deployed copy. $HOME is a vcsh work tree, so this is where
      # .config/nix actually lives on a running machine. It does not exist
      # yet; nothing here creates it.
      "/home/javier/.config/nix/private"
      # The checkout this flake is usually built from.
      "/home/javier/projects/txomonltd/nix-learn/dotfiles/.config/nix/private"
    ];
    description = ''
      Directories searched, in order, for this host's sops file. The first one
      holding a readable <hostname>.yaml wins and the rest are ignored.

      These are absolute paths and deliberately not nix paths. Naming one as a
      path literal would copy the file into the nix store, where it is
      world-readable, and would also require git to track it, because a flake
      copies nothing else. They are read at service start and at no other
      time.

      Nothing creates these directories. One that does not exist is skipped.
    '';
  };

  config = {
    # A string, not a path literal. sops.validateSopsFiles has to be off to
    # match: its only job is to hash every sops file at evaluation time, which
    # cannot work for a file outside the store and would defeat the point.
    sops.defaultSopsFile = resolved;
    sops.validateSopsFiles = false;

    # The machine's own age key: root-only, outside the repo and outside the
    # store. Made once per host with age-keygen, not generated from anything
    # the install produces, so it carries over unchanged when the host stops
    # being Arch. sops-nix's own default is the ed25519 ssh host keys, which
    # is no use here because services.openssh is off everywhere and the list
    # it reads from is therefore empty.
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # What happens when the search finds nothing.
    #
    # Installing secrets from a systemd unit rather than from the activation
    # script moves that failure from "nixos-rebuild refuses to switch" to
    # "the service refuses to start". A missing file fails the search, which
    # fails sops-install-secrets.service, and anything that asked for a secret
    # requires that unit and so does not come up.
    #
    # Not silent either way: sops-nix makes that unit RequiredBy
    # sysinit-reactivation.target, so a switch exits non-zero and names it.
    # What changes is that the new generation is still activated, because
    # nothing sops-shaped runs in the activation script any more. One missing
    # optional secret costs you that service and not the rest of the rebuild.
    sops.useSystemdActivation = true;

    # Only when something actually asked for a secret. With vanta off, which
    # is the default and the whole story on rosita and sam, sops-nix declares
    # no unit and there is nothing to attach to.
    systemd.services.sops-install-secrets =
      lib.mkIf (config.sops.secrets != { })
        {
          serviceConfig.ExecStartPre = [ "${search}" ];

          # The unit runs with DefaultDependencies=no. sops-nix orders it
          # after local-fs.target and asks for the mount holding its age key,
          # but it knows nothing about where the search looks, and these paths
          # are under /home. On these three hosts /home is on /, so this is
          # belt and braces; it stops being so the moment one of them is a
          # separate filesystem.
          unitConfig.RequiresMountsFor = cfg.searchPaths;
        };

    # The two commands README.md tells you to run. sops-nix installs only
    # sops-install-secrets, which is the activation half and no use for
    # editing a file or making a key. age-keygen is run as root and sops as
    # javier, so both go here rather than into the home profile.
    environment.systemPackages = [ pkgs.sops pkgs.age ];
  };
}
