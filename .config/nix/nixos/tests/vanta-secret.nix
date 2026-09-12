# What this check is, and what it is not.
#
# It plants a sops file and an age key inside the VM and proves the decryption
# path works there: the search picks a file up, sops-nix decrypts it, and
# /etc/vanta.conf ends up root:root 0600 holding the key. It then deletes the
# file and proves the service refuses to start.
#
# It does NOT exercise the real secrets.searchPaths. Those are
# /home/javier/..., a VM has no such user or file, and inventing one here
# would prove nothing about the machine. What carries over is everything
# downstream of the search: the ExecStartPre contract, the decryption, the
# ownership, and the Requires= that stops the daemon. Where the file comes
# from on a real host is the one part only that host can show.
#
# The node is pippin's own configuration.nix, so the real vanta.nix and the
# real modules/sops.nix are under test, with three things swapped:
#
#   - secrets.searchPaths, pointed at two directories under /run. The first
#     never exists, which is what proves the search skips a missing entry
#     instead of stopping at it.
#   - the age key, from the fixture below rather than /var/lib/sops-nix.
#   - services.vanta-agent.enable, which is off on every host.
#
# Both files are planted by an activation script. On this nixpkgs that runs
# from initrd-nixos-activation.service, before the switch-root, so it is
# strictly ahead of sops-install-secrets.service in the real root. The boot
# log in the check output shows the ordering if it is ever in doubt.
{ hostname, sopsModule }:

let
  # Invented, and never leaves this VM.
  agentKey = "test-placeholder-0123456789";
in

{ lib, ... }: {
  name = "vanta-secret";

  node.specialArgs = { inherit hostname; };
  node.pkgsReadOnly = false;

  nodes.${hostname} = { pkgs, lib, ... }:
    let
      # A throwaway age key and a sops file encrypted to it, both made at
      # build time. Neither is committed: a private key does not belong in a
      # public repository even when all it can read is a placeholder, and
      # generating the pair here means there is nothing to keep in step.
      fixture = pkgs.runCommand "vanta-secret-fixture"
        {
          nativeBuildInputs = [ pkgs.age pkgs.sops ];
        } ''
        export HOME=$TMPDIR
        mkdir -p $out

        age-keygen -o $out/key.txt 2>/dev/null

        printf '%s\n' \
          "vanta_conf: |" \
          "  {\"ACTIVATION_REQUESTED_NONCE\":0,\"AGENT_KEY\":\"${agentKey}\",\"OWNER_EMAIL\":\"nobody@example.invalid\",\"REGION\":\"US\",\"NEEDS_OWNER\":true}" \
          > plain.yaml

        sops --encrypt --input-type yaml --output-type yaml \
          --age "$(age-keygen -y $out/key.txt)" plain.yaml > $out/secrets.yaml
      '';
    in
    {
      imports = [ sopsModule ../hosts/${hostname}/configuration.nix ];

      virtualisation.memorySize = 4096;
      virtualisation.cores = 2;
      virtualisation.diskSize = 8192;
      virtualisation.qemu.options = [ "-vga std" ];

      services.vanta-agent.enable = true;

      secrets.searchPaths = lib.mkForce [
        "/run/no-such-secrets-dir"
        "/run/test-secrets"
      ];

      sops.age.keyFile = lib.mkForce "/run/age-keys.txt";

      system.activationScripts.testSecrets = lib.stringAfter [ "specialfs" ] ''
        install -D -m 0400 ${fixture}/secrets.yaml /run/test-secrets/${hostname}.yaml
        install -m 0400 ${fixture}/key.txt /run/age-keys.txt
      '';
    };

  testScript = ''
    ${hostname}.wait_for_unit("multi-user.target")

    with subtest("the search skipped the missing directory and took the next"):
        ${hostname}.succeed("systemctl is-active sops-install-secrets.service")
        ${hostname}.succeed(
            "readlink /run/sops-source.yaml | grep -x /run/test-secrets/${hostname}.yaml"
        )

    with subtest("and what it found is not a store path"):
        # The point of naming the file by absolute path rather than by a nix
        # path literal. A path literal would have been copied into the store,
        # which is world-readable.
        target = ${hostname}.succeed("readlink -f /run/sops-source.yaml").strip()
        assert not target.startswith("/nix/store"), target

    with subtest("the agent key is decrypted into place"):
        # /etc/vanta.conf is a symlink; sops-install-secrets keeps the file
        # itself on the /run/secrets.d ramfs and points the requested path at
        # it through /run/secrets, so owner and mode belong to the target.
        ${hostname}.succeed("test -L /etc/vanta.conf")
        ${hostname}.succeed(
            "readlink /etc/vanta.conf | grep -x /run/secrets/vanta_conf"
        )
        ${hostname}.succeed(
            "stat -L -c '%U:%G:%a' /etc/vanta.conf | grep -x 'root:root:600'"
        )
        conf = ${hostname}.succeed("cat /etc/vanta.conf")
        assert '"AGENT_KEY":"${agentKey}"' in conf, conf

    with subtest("and by root only"):
        ${hostname}.fail("su javier -c 'cat /etc/vanta.conf'")

    with subtest("the daemon has the unit and state the secret is for"):
        ${hostname}.succeed("systemctl cat vanta-agent.service")
        ${hostname}.wait_until_succeeds("test -x /var/vanta/metalauncher")
        ${hostname}.succeed("test -x /run/current-system/sw/bin/vanta-cli")

    with subtest("with no file anywhere, the service refuses to start"):
        # The one thing absolute paths give up: nothing can catch a missing
        # file at evaluation time, so it has to be caught here.
        ${hostname}.succeed("systemctl stop vanta-agent.service")
        ${hostname}.succeed("rm -rf /run/test-secrets")
        ${hostname}.fail("systemctl restart sops-install-secrets.service")

        # And the message names every directory it looked in, in order.
        journal = ${hostname}.succeed(
            "journalctl -u sops-install-secrets.service --no-pager"
        )
        for line in ["no secrets file for ${hostname}",
                     "/run/no-such-secrets-dir",
                     "/run/test-secrets"]:
            assert line in journal, f"{line!r} missing from:\n{journal}"

        # vanta-agent requires that unit, so it does not come up either.
        ${hostname}.fail("systemctl start vanta-agent.service")
        ${hostname}.fail("systemctl is-active vanta-agent.service")
  '';
}
