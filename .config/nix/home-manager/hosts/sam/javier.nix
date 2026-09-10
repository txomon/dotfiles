{ config
, pkgs
, ...
}: {
  imports = [
    ../../fleet-control
    ../../modules
  ];
  home = {
    username = "javier";
    stateVersion = "26.11";
    homeDirectory = "/home/${config.home.username}";
    packages = [ ];
  };
  fleet-control.atm10.enable = true;

  # sam is Arch, and /etc/profile.d/nix-daemon.sh appends the nix share
  # directories rather than prepending them, so an Arch .desktop file wins
  # over the nix one of the same name. systemd reads this at session start,
  # which is what GNOME's launcher inherits.
  systemd.user.sessionVariables.XDG_DATA_DIRS =
    "${config.home.profileDirectory}/share:\${XDG_DATA_DIRS}";

  programs = {
    antigravity-cli.enable = true;
    bash.enable = true;
    chromium.enable = true;
    direnv.enable = true;
    elvish.enable = true;
    firefox.enable = true;
    gcloud.enable = true;
    google-chrome.enable = true;
    home-manager.enable = true;
    jetbrains = {
      enable = true;
      ides = [ "goland" "pycharm" ];
    };
    ringboard.enable = true;
    slack.enable = true;
    starship.enable = true;
    telegram-desktop.enable = true;
    tmux = {
      enable = true;
      prefix = "C-j";
      # Hue in degrees. The tmux module fixes saturation and luminance, so
      # this is the only colour choice a host makes. gandalf is 0 (red) and
      # durin is 240 (blue).
      palette.hue = 158;
    };
    txomon-android.enable = true;
    txomon-claude.enable = true;
    txomon-docker.enable = true;
    txomon-egpu.enable = true;
    txomon-git.enable = true;
    txomon-graphical.enable = true;
    txomon-kube.enable = true;
    txomon-notify.enable = true;
    vim.enable = true;
  };
}
