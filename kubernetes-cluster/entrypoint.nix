let
  kubeMasterHostname = "kubernetes-master";
  kubeMasterAPIServerPort = 443;
in
{
  network.description = "Kubernetes Master";

  kubernetes-master = {
    config, pkgs, ...
  } : {
    services.kubernetes = {
      roles = [ "master" ];
      masterAddress = kubeMasterHostname;
      apiserver = {
        securePort = kubeMasterAPIServerPort;
        advertiseAddress = config.networking.privateIPv4;
      };
      addons.dns.enable = true;
    };
    networking.firewall.allowedTCPPorts = [ 8888 443 22 ];
  };

  kubernetes-nodes = {
    config, pkgs, ...
  } :
  let
    api = "https://${kubeMasterHostname}:${(builtins.toString kubeMasterAPIServerPort)}";
  in
  {
    services.kubernetes = {
      roles = [ "node" ];
      masterAddress = kubeMasterHostname;
      easyCerts = true;

      kubelet.kubeconfig.server = api;
      apiserverAddress = api;

      addons.dns.enable = true;

      kubelet.extraOpts = "--fail-swap-on=false";
    };

    networking.firewall.enable = false;
  };
}
