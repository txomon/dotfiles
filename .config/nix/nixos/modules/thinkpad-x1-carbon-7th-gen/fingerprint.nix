# Synaptics Prometheus MIS Touch fingerprint reader, USB 06cb:00bd.
#
# Translated from
# /home/javier/projects/txomonltd/lenovo-x1-carbon/docs/02-fingerprint.md.
# Both machines carry the same reader, confirmed in each host's lsusb.
{ ... }: {
  # No driver, firmware or kernel work: libfprint has supported the Prometheus
  # family through its `synaptics` driver since 1.90 and nixpkgs ships 1.94.100.
  # fprintd is dbus-activated, so enabling it is about having the daemon, the
  # dbus service and pam_fprintd.so on the system, not about a running unit.
  services.fprintd.enable = true;

  # security.pam.services.<name>.fprintAuth defaults to services.fprintd.enable,
  # which wires pam_fprintd.so into EVERY PAM service. That is too wide.
  #
  # Where it is wanted, and left on by that default:
  #   gdm-fingerprint  the greeter's dedicated fingerprint stack. GDM runs it
  #                    concurrently with gdm-password, which is the only reason
  #                    a graphical login can offer both at once while a
  #                    terminal cannot: PAM itself is serialised.
  #   polkit-1         the GNOME agent dialog accepts a finger.
  #   sudo             inert while wheel is NOPASSWD, correct if that is ever
  #                    removed.
  #
  # gdm-password does NOT get it, and must not: it is `auth substack login`,
  # so a fingerprint module there would block the password prompt. nixpkgs'
  # gdm module already sets login.fprintAuth = false for exactly that reason.
  #
  # Where it is turned off below: stacks that PAM runs serially and where no
  # reader is reachable. pam_fprintd holds the conversation for its timeout
  # (30s by default) and typing a password during that window does nothing, so
  # on a TTY it reads as a hang.
  #
  # The control is "sufficient" in these stacks, so a failed, absent or
  # unenrolled reader always falls through to the password stack. Nothing here
  # can lock anyone out.
  security.pam.services = {
    # Redundant with the gdm module's own mkIf above, and kept anyway: this is
    # what keeps the TTY stack clean if GDM is ever swapped out.
    login.fprintAuth = false;
    su.fprintAuth = false;
    su-l.fprintAuth = false;
    runuser.fprintAuth = false;
    runuser-l.fprintAuth = false;
    # No sshd entry: openssh is not enabled on these hosts, and naming the
    # service here would create an /etc/pam.d/sshd for a daemon that does not
    # run. Turn it off there too if openssh is ever enabled; a remote session
    # has no reader to present a finger to.
  };

  # Enrollment is physical and cannot be declared. After the first boot:
  #
  #   fprintd-enroll                        right index, nine presses
  #   fprintd-enroll -f left-index-finger
  #   fprintd-list javier
  #
  # or Settings > System > Users > Fingerprint Login. This is a match-on-chip
  # sensor, so templates live on the reader and /var/lib/fprint holds only
  # fprintd's index; clear prints with `fprintd-delete`, never by deleting that
  # directory, which only desynchronises the two.
}
