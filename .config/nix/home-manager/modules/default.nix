{ config
, pkgs
, ...
}: {
  imports = [
    ./tmux
    ./txomon-android
    ./txomon-claude
    ./txomon-docker
    ./txomon-git
    ./txomon-notify
    ./vim
  ];
}
