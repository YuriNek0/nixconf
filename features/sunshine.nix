{ ... }: {
  flake.modules.features.sunshine = { ... }: {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = false;
      openFirewall = true;
    };
  };
}
