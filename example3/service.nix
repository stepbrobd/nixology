{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy = {
    virtualHosts."nixolo.gy" = {
      extraConfig = "redir https://github.com/stepbrobd/nixology/tree/master{uri}";
      serverAliases = [ "*.nixolo.gy" ];
    };
  };
}
