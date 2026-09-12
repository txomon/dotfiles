# Boots a host's real configuration in a headless VM and asserts against the
# running system. Called once per host from flake.nix, which exposes the results
# as checks.x86_64-linux.<host>-boots.
#
# The node imports the host's own configuration.nix, so what boots here is that
# file and everything it imports, not a restatement of it. Only the things a VM
# cannot have are replaced, and nearly all of that is done for us:
# nixos/modules/virtualisation/qemu-vm.nix applies mkVMOverride to fileSystems,
# swapDevices, boot.initrd.luks.devices and services.xserver.videoDrivers, which
# beats the normal-priority definitions in the hardware files.
#
# So this is NOT the whole of what the machine runs. The nixos-hardware model
# module is added in flake.nix's mkHost rather than in configuration.nix, and is
# therefore absent from the node: nothing it sets is exercised here. Neither is
# anything qemu-vm overrode, which is exactly the real disk layout, the LUKS
# unlock and, on pippin, the NVIDIA driver.
#
# `nix flake check` only evaluates nixosConfigurations. These checks are the
# part that actually builds and boots something.
{ hostname, thinkpad, sopsModule }:

{ lib, ... }: {
  name = "${hostname}-boots";

  # modules/networking.nix reads the hostname the same way the real host does.
  node.specialArgs = { inherit hostname; };

  # runNixOSTest hands every node a prebuilt `pkgs` and pins the nixpkgs.*
  # options read-only. modules/nix.nix sets nixpkgs.config (allowUnfree and the
  # insecure Electron), so the node has to construct its own pkgs instead.
  # Costs some evaluation time and buys the thing the test is for: the node is
  # built from the host's own nixpkgs settings rather than from the test's.
  node.pkgsReadOnly = false;

  nodes.${hostname} = {
    # sops-nix comes in from flake.nix, not from the module tree, so a node
    # built from configuration.nix alone would not have the options
    # modules/sops.nix sets. Nothing here declares a secret: vanta is off on
    # every host, so no sops unit is generated and no file is searched for.
    # The vanta-secret check is where a secret is actually installed.
    imports = [ sopsModule ../hosts/${hostname}/configuration.nix ];

    # GNOME, GDM and the rest do not come up in the 1024MB default.
    virtualisation.memorySize = 4096;
    virtualisation.cores = 2;
    virtualisation.diskSize = 8192;

    # The graphical target is what most of this test is about, so the VM needs
    # a framebuffer. Without this the node is headless and GDM has nothing to
    # start on.
    virtualisation.qemu.options = [ "-vga std" ];
  };

  testScript = ''
    ${hostname}.wait_for_unit("multi-user.target")

    with subtest("the desktop comes up"):
        ${hostname}.wait_for_unit("display-manager.service")
        # GDM's own greeter session, which is as far as an unattended test can
        # get: past this point something has to type a password.
        ${hostname}.wait_until_succeeds("loginctl list-sessions | grep -q gdm", timeout=120)

    with subtest("the groups the modules promise exist"):
        for group in ["wireshark", "docker", "libvirtd", "networkmanager"]:
            ${hostname}.succeed(f"getent group {group}")
        # No adbusers. programs.adb was removed from nixpkgs (systemd 258 does
        # the uaccess rules), so nothing creates that group any more.
        ${hostname}.fail("getent group adbusers")

    with subtest("javier is in all of them"):
        groups = ${hostname}.succeed("id -nG javier").split()
        for group in ["wheel", "networkmanager", "docker", "wireshark", "libvirtd"]:
            assert group in groups, f"javier is not in {group}: {groups}"

    with subtest("the daemons are up"):
        ${hostname}.wait_for_unit("docker.socket")
        ${hostname}.wait_for_unit("libvirtd.service")
        ${hostname}.wait_for_unit("NetworkManager.service")

    with subtest("the system packages are on PATH"):
        for binary in ["nmap", "tcpdump", "dig", "jq", "rsync", "inxi", "adb",
                       "glxinfo", "vulkaninfo", "virt-install", "wireshark"]:
            ${hostname}.succeed(f"test -x /run/current-system/sw/bin/{binary}")

    with subtest("the udev rules land where they were put"):
        # 59, not 99: systemd runs the uaccess builtin from 73-seat-late.rules,
        # so a TAG+="uaccess" written into 99-local.rules never fires.
        ${hostname}.succeed("grep -q 'vial:f64c2b3c' /etc/udev/rules.d/59-vial.rules")
        # From pkgs.xppen_4, via programs.xppen.
        ${hostname}.succeed("grep -q '28bd' /etc/udev/rules.d/10-xp-pen.rules")

    with subtest("wireshark can capture without root"):
        # Not a setuid wrapper: programs.wireshark gives dumpcap
        # cap_net_raw,cap_net_admin+eip and mode u+rx,g+x as root:wireshark, so
        # group membership is the whole gate. The capability itself is set by
        # security.wrappers and is asserted at config level, not from in here.
        ${hostname}.succeed("test -e /run/wrappers/bin/dumpcap")
        ${hostname}.succeed("stat -c %U:%G /run/wrappers/bin/dumpcap | grep -x root:wireshark")

    with subtest("locale and timezone"):
        ${hostname}.succeed("test -L /etc/localtime")
        ${hostname}.succeed("grep -q 'LANG=en_US.UTF-8' /etc/locale.conf")
  '' + lib.optionalString thinkpad ''

    with subtest("the fingerprint reader is wired into the right PAM stacks"):
        ${hostname}.succeed("test -x /run/current-system/sw/bin/fprintd-enroll")
        ${hostname}.succeed("systemctl cat fprintd.service")
        for service in ["polkit-1", "sudo", "gdm-fingerprint"]:
            ${hostname}.succeed(f"grep -q pam_fprintd /etc/pam.d/{service}")
        # And explicitly not into the serial stacks, where the module would
        # hold the conversation for its timeout with no reader to answer it.
        # gdm-password is in that list because it is `auth substack login`:
        # a fingerprint module there would block the greeter's password box,
        # which is why GDM runs gdm-fingerprint as a separate conversation.
        for service in ["login", "su", "su-l", "gdm-password"]:
            ${hostname}.fail(f"grep -q pam_fprintd /etc/pam.d/{service}")

    with subtest("the modem pieces are the git build, not nixpkgs 1.24.2"):
        version = ${hostname}.succeed("ModemManager --version")
        assert "1.25.95" in version, f"stock ModemManager in the closure: {version}"
        # The FCC unlock script for this modem exists only in git main. Its
        # presence is the thing that proves the override took.
        ${hostname}.succeed(
            "test -x '/run/current-system/sw/share/ModemManager/fcc-unlock.available.d/8086:7360'"
        )

    with subtest("the FCC unlock runs before the daemon, not as a dispatcher"):
        unit = ${hostname}.succeed("systemctl cat ModemManager.service")
        assert "wwan-fcc-unlock" in unit, f"no ExecStartPre drop-in:\n{unit}"
        # Dispatcher mode is upstream issue 1028: daemon and script fight over
        # the same RPC channel. /etc/ModemManager/fcc-unlock.d must stay empty,
        # whether or not the directory itself exists.
        ${hostname}.fail(
            'test -n "$(ls -A /etc/ModemManager/fcc-unlock.d 2>/dev/null)"'
        )

    with subtest("PCI runtime PM is pinned off for the modem"):
        ${hostname}.succeed("grep -q '0x7360' /etc/udev/rules.d/99-local.rules")
        ${hostname}.succeed("grep -q 'power/control.*on' /etc/udev/rules.d/99-local.rules")
  '';
}
