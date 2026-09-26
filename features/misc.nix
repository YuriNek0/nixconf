_: {
  flake.modules.features.misc =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        openssl
      ];
    };
}
