{ pkgs, ... }: {
  # Userspace driver for the MX Master. Ships as a systemd unit plus a D-Bus
  # service; with an empty config it applies the device defaults.
  services.logiops.enable = true;

  # Vial talks to the keyboard over hidraw.
  #
  # pkgs.vial does ship etc/udev/rules.d/92-viia.rules, but that rule is
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
  # which opens every hidraw node on the machine to everyone. The rule below is
  # the one pippin already runs under Arch, scoped to the one keyboard by serial.
  #
  # It goes in via services.udev.packages rather than services.udev.extraRules:
  # extraRules lands in 99-local.rules, and systemd runs the uaccess builtin
  # from 73-seat-late.rules, so a TAG+="uaccess" set at 99 is applied too late
  # to have any effect. 59 is the number Arch uses for the same reason.
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/59-vial.rules" ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '')
  ];

  # The two XP-Pen rules (uinput static node, and USB vendor 28bd) come from
  # pkgs.xppen_4 via programs.xppen in programs.nix, so they are not repeated
  # here. The packaged pair assigns MODE:="0666" where Arch assigns 0660 with
  # TAG+="uaccess"; looser than needed, but it lands at 10-xp-pen.rules, early
  # enough that the tag would work if it carried one.
}
