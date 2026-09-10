{ config
, lib
, pkgs
, ...
}: {
  options.programs.txomon-kube = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "kubectl, plus kubetoken for copying the context's access token";
    };
  };

  config = lib.mkIf config.programs.txomon-kube.enable {
    home.packages = [
      pkgs.kubectl

      (pkgs.writeShellApplication {
        name = "kubetoken";
        runtimeInputs = [
          pkgs.kubectl
          pkgs.coreutils # timeout
          pkgs.gnugrep
          pkgs.gnused
          pkgs.xclip
        ];
        text = builtins.readFile ./kubetoken.sh;
      })
    ];
  };
}
