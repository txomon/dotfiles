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
    ./factorio
    ./gcloud
    ./gimp
    ./gnome-browser-connector
    ./gnome-firmware
    ./gnome-network-displays
    ./gnome-power-manager
    ./gnome-tweaks
    ./helvum
    ./jadx
    ./jetbrains
    ./logseq
    ./masterpdfeditor
    ./meld
    ./pcon-planner
    ./ringboard
    ./slack
    ./spotify
    ./starship
    ./telegram-desktop
    ./theclicker
    ./tmux
    ./transmission-remote-gtk
    ./transmission_4-gtk
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
    ./vlc
    ./wine
    ./winetricks
    ./xdotool
  ];
}
