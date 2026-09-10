{ config
, pkgs
, ...
}: {
  imports = [
    ./bash
    ./elvish
    ./gcloud
    ./jetbrains
    ./ringboard
    ./slack
    ./starship
    ./telegram-desktop
    ./tmux
    ./txomon-android
    ./txomon-claude
    ./txomon-docker
    ./txomon-egpu
    ./txomon-git
    ./txomon-graphical
    ./txomon-kube
    ./txomon-notify
    ./vim
  ];
}
