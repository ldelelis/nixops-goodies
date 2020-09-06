let
  kubeMasterHostname = "kubernetes-master";
  kubeMasterAPIServerPort = 443;
  kubernetesNode = {
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
in
{
  network.description = "Kubernetes Cluster";

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

    # FIXME: this is.... bad. etcd depends on some certificates generated during runtime by
    # what assume is certmgr. Since the cert creation is done _after_ start, we can't depend
    # on the service itself, but we can give an educated guess on how long it takes to generate
    # these certs
    # Theres's probably a better way to do this.... but I can't come up with it
    # PRs welcome :)
    systemd.services.etcd.serviceConfig.ExecStartPre = "/run/current-system/sw/bin/sleep 30";

    networking.firewall.allowedTCPPorts = [ 8888 443 22 ];
  };

  kubernetes-node-1 = kubernetesNode;
}
