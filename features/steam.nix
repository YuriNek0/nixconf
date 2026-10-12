{ ... }:
{
  flake.modules.features.steam =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
        };
        gamescope = {
          enable = true;
          capSysNice = false;
        };
      };
    };
}
