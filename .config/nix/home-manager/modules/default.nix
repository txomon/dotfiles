{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./txomon-android
    ./txomon-docker
    ./vim
  ];
}