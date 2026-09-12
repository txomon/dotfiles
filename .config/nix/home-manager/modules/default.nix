{ config
, pkgs
, ...
}: {
  imports = [
    ./autofirma
    ./bash
    ./computer-use-linux
    ./configuradorfnmt
    ./discord
    ./elvish
    ./gcloud
    ./jetbrains
    ./pcon-planner
    ./pcon-planner-legacy
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
    ./vanta-agent
    ./vim
  ];
}
