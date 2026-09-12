# ModemManager and libqmi built from git main, which is what the XMM7360 needs.
#
# Everything here is a translation of
# /home/javier/projects/txomonltd/lenovo-x1-carbon/docs/03-wwan-modem.md and
# 04-building-packages.md, which got this modem working on Arch on 2026-09-09.
# The reasoning is recorded there; the pinned commits and the dependency between
# the two are reproduced here.
#
# This is a plain function returning one package, NOT an overlay. An overlay
# replacing pkgs.modemmanager would pull gnome-shell, gnome-settings-daemon and
# gnome-control-center into a rebuild against 1.25.95's libmm-glib headers,
# which they do not compile against. Only the daemon needs the new code:
# everything else talks to it over D-Bus, where 1.24 and 1.25.95 agree, so the
# rest of the system keeps the nixpkgs libmm-glib. It reaches the system through
# networking.modemmanager.package in modem.nix and nowhere else.
#
# Retire this file when nixpkgs carries ModemManager >= 1.26. Check the release
# for src/plugins/intel/mm-broadband-modem-xmm7360.c and for a
# share/ModemManager/fcc-unlock.available.d/8086:7360 script; if both are
# present, delete this and drop the package line in modem.nix.
{ pkgs }:

let
  # 1.39.1, 2026-08-16. ModemManager main uses QMI_WDS_PDP_TYPE_NON_IP and
  # QMI_DATA_ENDPOINT_TYPE_ETHERNET, both marked "Since 1.40" and absent from
  # the 1.38.0 release headers nixpkgs ships, so it does not compile against it.
  #
  # Also scoped: pkgs.libqmi itself is untouched, so fwupd, NetworkManager and
  # the rest keep the nixpkgs build. The soname is the same either way
  # (libqmi-glib.so.5, from a libtool triple of 17.0.12) and both blocking
  # symbols are new enum values rather than signature changes, so the two
  # coexist.
  libqmi-xmm = pkgs.libqmi.overrideAttrs (old: {
    version = "1.39.1-unstable-2026-08-16";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "mobile-broadband";
      repo = "libqmi";
      rev = "b7913df8b49330956f0337dcc6255f63751fdda1";
      hash = "sha256-nAWvwr18x9729QoriotKlKYBczfpDAOOfyHlJyeRttw=";
    };
  });
in
(pkgs.modemmanager.override { libqmi = libqmi-xmm; }).overrideAttrs (old: {
  # git main at 2026-09-08. The released 1.24.2 recognises the modem and then
  # refuses it on purpose: "Intel XMM7360 in RPC mode not supported". main
  # carries the implementation in src/plugins/intel/, and the 8086:7360 FCC
  # unlock script that no release contains.
  #
  # This commit is past the 2026-05-24 merge of the xmm7360-assert-cleanup
  # branch. Anything at or before the 1.25.95-dev tag (2025-11-24) crashes on
  # g_assert() in the RPC parser against this modem, upstream issue 1034, so do
  # not move this pin backwards.
  version = "1.25.95-unstable-2026-09-08";
  src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = "ModemManager";
    rev = "e1f8061541c974d046e264b1069716109a607e5e";
    hash = "sha256-22SZ+SyI9NgDNa12y5kKlxj9B9MDfqpHNLjHw6xqDH8=";
  };
})
