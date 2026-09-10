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
    packages = [
      pkgs.starship
    ];
  };
  fleet-control.atm10.enable = true;

  programs = {
    antigravity-cli.enable = true;
    bash.enable = true;
    direnv.enable = true;
    elvish.enable = true;
    gcloud.enable = true;
    home-manager.enable = true;
    tmux = {
      enable = true;
      prefix = "C-j";
      # Hue in degrees. The tmux module fixes saturation and luminance, so
      # this is the only colour choice a host makes. gandalf is 0 (red) and
      # durin is 240 (blue).
      palette.hue = 120;
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
