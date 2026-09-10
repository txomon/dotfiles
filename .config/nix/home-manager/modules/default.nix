{ config
, pkgs
, ...
}: {
  imports = [
    ./bash
    ./elvish
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
