{ config
, pkgs
, ...
}: {
  imports = [
    ./tmux
    ./txomon-android
    ./txomon-docker
    ./txomon-git
    ./txomon-notify
    ./vim
  ];
}
