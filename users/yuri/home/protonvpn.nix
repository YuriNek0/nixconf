_: {
  flake.modules.users.yuri.home.protonvpn =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        proton-vpn
        wireguard-tools
      ];
    };
}
