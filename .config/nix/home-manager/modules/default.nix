{ config
, pkgs
, ...
}: {
  imports = [
    ./tmux
    ./txomon-android
    ./txomon-docker
    ./vim
  ];
}
