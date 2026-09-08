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
    bat.enable = true;
    android-utils.enable = true;
  };
}