# Boots pippin with services.vanta-agent on and checks two things the rest of
# the checks cannot: that the agent key arrives decrypted at /etc/vanta.conf,
# and that losing the file stops the service rather than being ignored.
# Exposed from flake.nix as checks.x86_64-linux.vanta-secret.
#
# The node is pippin's own configuration.nix, so what is under test is the real
# vanta.nix and the real modules/sops.nix, with three things swapped:
#
#   - secrets.searchPaths, pointed at two directories under /run. The first
#     never exists, which is what proves the search skips a missing entry
#     instead of stopping at it.
#   - the age key, which becomes the one committed next to this file. A VM has
#     no /var/lib/sops-nix/key.txt and nothing should give it a real one.
#   - services.vanta-agent.enable, which is off on every host.
#
# Both files are planted by an activation script. On this nixpkgs that runs
# from initrd-nixos-activation.service, before the switch-root, so it is
# strictly ahead of sops-install-secrets.service in the real root. The boot
# log in the check output shows the ordering if it is ever in doubt.
{ hostname, sopsModule }:

{ lib, ... }: {
  name = "vanta-secret";

  node.specialArgs = { inherit hostname; };
  node.pkgsReadOnly = false;

  nodes.${hostname} = {
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
      install -D -m 0400 ${./vanta-secret/vanta.yaml} /run/test-secrets/${hostname}.yaml
      install -m 0400 ${./vanta-secret/age-key.txt} /run/age-keys.txt
    '';
  };

  testScript = ''
    ${hostname}.wait_for_unit("multi-user.target")

    with subtest("the search skipped the missing directory and took the next"):
        ${hostname}.succeed("systemctl is-active sops-install-secrets.service")
        ${hostname}.succeed(
            "readlink /run/sops-source.yaml | grep -x /run/test-secrets/${hostname}.yaml"
        )

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
        assert '"AGENT_KEY":"test-placeholder-0123456789"' in conf, conf

    with subtest("and by root only"):
        ${hostname}.fail("su javier -c 'cat /etc/vanta.conf'")

    with subtest("the daemon has the unit and state the secret is for"):
        ${hostname}.succeed("systemctl cat vanta-agent.service")
        ${hostname}.wait_until_succeeds("test -x /var/vanta/metalauncher")
        ${hostname}.succeed("test -x /run/current-system/sw/bin/vanta-cli")

    with subtest("with no file anywhere, the service refuses to start"):
        # The whole reason absolute paths need a runtime answer: nothing can
        # catch this at evaluation time, so it has to be caught here.
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
