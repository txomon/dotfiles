{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "javier";
    stateVersion = "26.11";
    homeDirectory = "/home/${config.home.username}";
    packages = [
      pkgs.starship
    ];
  };
}