# Intel XMM7360 / Fibocom L850-GL 4G modem, PCI 8086:7360 at 02:00.0.
#
# Translated from
# /home/javier/projects/txomonltd/lenovo-x1-carbon/docs/03-wwan-modem.md, which
# got this modem working on Arch on 2026-09-09 and records why each piece is
# needed. Three things had to be fixed and a fourth pre-empted; all four are
# below. Both machines carry the same modem, confirmed in each host's lspci.
#
# No out-of-tree kernel driver. The old xmm7360-pci driver and its Python
# open_xdatachannel.py are obsolete: the mainline `iosm` driver exposes the RPC
# channel as /dev/wwan0xmmrpc0 and ModemManager main speaks the protocol over
# it. Nothing goes in boot.extraModulePackages.
{ config, lib, pkgs, ... }:

let
  # Problems 1 and 2: nixpkgs has ModemManager 1.24.2, which refuses this modem
  # outright, and libqmi 1.38.0, which ModemManager main will not compile
  # against. Both are rebuilt from git main; the pins, and why this is scoped to
  # the daemon rather than done as an overlay, are in modem-packages.nix.
  modemmanager = import ./modem-packages.nix { inherit pkgs; };

  # The upstream unlock script run standalone, not as a ModemManager dispatcher.
  # See the ExecStartPre comment below for why.
  fccUnlock = pkgs.writeShellApplication {
    name = "wwan-fcc-unlock";
    # The upstream script builds its binary RPC frames with xxd. Without it on
    # PATH it writes an empty request and then blocks forever on the reply, so
    # it is supplied here rather than hoped for. writeShellApplication exports
    # PATH, so the script inherits it.
    runtimeInputs = [ pkgs.tinyxxd pkgs.coreutils pkgs.bash ];
    text = ''
      script=${modemmanager}/share/ModemManager/fcc-unlock.available.d/8086:7360

      # ExecStartPre can fire before iosm has attached the ports on a cold boot.
      for _ in {1..30}; do
        [ -c /dev/wwan0xmmrpc0 ] && break
        sleep 1
      done

      # No modem: card removed, or WWAN disabled in BIOS. Not an error, and
      # ModemManager should not look broken because of it.
      if [ ! -c /dev/wwan0xmmrpc0 ]; then
        echo "wwan-fcc-unlock: no XMMRPC port, nothing to unlock" >&2
        exit 0
      fi

      if [ ! -r "$script" ]; then
        echo "wwan-fcc-unlock: $script missing; ModemManager too old?" >&2
        exit 1
      fi

      # The script takes a D-Bus path it ignores, then port names, and picks the
      # one whose /sys/class/wwan/<port>/type reads XMMRPC.
      exec timeout 30 bash "$script" dummy wwan0xmmrpc0
    '';
  };
in
{
  # networking.networkmanager.enable already sets `enable` by mkDefault. Stated
  # anyway: on these two hosts ModemManager is the point, not a side effect.
  #
  # The package swap lands here and only here. GNOME's network panel keeps the
  # nixpkgs libmm-glib and reaches this daemon over D-Bus, which is what makes
  # the narrow override possible.
  networking.modemmanager = {
    enable = true;
    package = modemmanager;
  };

  # Problem 3: the modem ships FCC locked and will not leave CFUN: 4 (radio
  # off) until the host answers a challenge. The unlock script for 8086:7360
  # exists only in ModemManager git main, which is the other reason for the
  # rebuild.
  #
  # networking.modemmanager.fccUnlockScripts is deliberately not used. It
  # symlinks the script into /etc/ModemManager/fcc-unlock.d/, which makes
  # ModemManager run it as a dispatcher while the daemon itself holds
  # /dev/wwan0xmmrpc0. Both then read and write the same RPC channel, the
  # exchanges interleave and time out, and the daemon can go down with them:
  # upstream ModemManager issue 1028. Running it from ExecStartPre means it has
  # the port to itself and is finished before the daemon opens it.
  #
  # The "-" prefix means a failure here does not stop ModemManager. A daemon up
  # and degraded beats no daemon. Re-running on every start is harmless; the
  # unlock persists until the modem loses power and the script then logs
  # "FCC already unlocked, nothing to do."
  systemd.services.ModemManager.serviceConfig.ExecStartPre = [
    "-${lib.getExe fccUnlock}"
  ];

  # Problem 4: PCI runtime power management crashes this modem's firmware,
  # upstream ModemManager issue 992. Recovery needs a full power-off, because
  # neither a warm reboot nor a driver reload cuts the modem's power, so the
  # fault survives both. It presents as "msg timeout" and "PORT open refused,
  # phase A-CD_READY" in dmesg, with the AT ports returning I/O errors, which
  # ModemManager reports as "Failed to find primary AT port" and points nowhere
  # near the cause.
  #
  # Matched by vendor and device rather than by 0000:02:00.0, so it holds if
  # the address ever moves. 99-local.rules is late on purpose: this needs to be
  # the last write to the attribute.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7360", ATTR{power/control}="on"
  '';

  # The Arch machine also needed /etc/tlp.d/99-wwan-nopm.conf, because TLP sets
  # RUNTIME_PM_ON_BAT=auto and would undo the rule above on battery. TLP is not
  # enabled here (GNOME brings power-profiles-daemon, which conflicts with it).
  # If services.tlp is ever turned on, add:
  #   services.tlp.settings.RUNTIME_PM_DENYLIST = "0000:02:00.0";
  # and not RUNTIME_PM_DRIVER_DENYLIST, which replaces TLP's shipped list
  # wholesale and would silently un-denylist amdgpu, nvidia and the rest.

  # Remaining step, physical: insert a SIM. Until then the modem reaches
  # "failed reason: sim-missing", which means everything above worked.
}
