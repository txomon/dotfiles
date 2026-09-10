{ config
, pkgs
, ...
}: {
  imports = [
    ./bash
    ./elvish
    ./gcloud
    ./jetbrains
    ./starship
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
