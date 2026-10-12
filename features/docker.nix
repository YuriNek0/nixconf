_: {
  flake.modules.features.docker = _: {
    boot.kernelModules = [ "overlay" ];
    virtualisation = {
      docker.enable = true;
    };
  };
}
