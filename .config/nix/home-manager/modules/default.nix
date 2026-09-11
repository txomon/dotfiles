{ config
, pkgs
, ...
}: {
  imports = [
    ./autofirma
    ./bash
    ./configuradorfnmt
    ./discord
    ./elvish
    ./gcloud
    ./jetbrains
    ./pcon-planner
    ./ringboard
    ./slack
    ./starship
    ./telegram-desktop
    ./tmux
    ./txomon-android
    ./txomon-claude
    ./txomon-cli
    ./txomon-docker
    ./txomon-egpu
    ./txomon-git
    ./txomon-graphical
    ./txomon-kube
    ./txomon-notify
    ./vim
  ];
}
