{ config
, pkgs
, ...
}: {
  imports = [
    ./tmux
    ./txomon-android
    ./txomon-claude
    ./txomon-docker
    ./txomon-egpu
    ./txomon-git
    ./txomon-notify
    ./vim
  ];
}
