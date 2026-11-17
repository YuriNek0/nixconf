_: {
  flake.modules.features.protonmail-bridge =
    { lib, pkgs, ... }:
    let
      credentialPackages = with pkgs; [
        pass
        gnupg
      ];
    in
    {
      # Initialize pass and log in with protonmail-bridge --cli as the service user.
      environment.systemPackages = credentialPackages;

      services.protonmail-bridge = {
        enable = true;
        path = credentialPackages;
      };

      systemd.user.services.protonmail-bridge = {
        # Headless hosts do not start graphical-session.target.
        wantedBy = lib.mkForce [ "default.target" ];
        after = lib.mkForce [ ];
        serviceConfig.RestartSec = "10s";
      };
    };
}
