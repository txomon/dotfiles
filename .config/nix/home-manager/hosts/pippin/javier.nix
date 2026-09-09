{
  config,
  pkgs,
  ...
}: {
  imports = [
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
  programs = {
    antigravity-cli.enable = true;
    home-manager.enable = true;
    txomon-android.enable = true;
    txomon-docker.enable = true;
    vim.enable = true;
  };
}