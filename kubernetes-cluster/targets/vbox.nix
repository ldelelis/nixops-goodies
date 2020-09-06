let
  baseImage = import (builtins.fetchGit {
    url = "https://github.com/DavHau/nixops-vbox-base-image";
    ref = "v1.0.0";
    rev = "54bad1f546919404c105d1a734d599de87740f56";
  }) {
    pkgs = import <nixpkgs> {};
    # define nixpkgs channel and revision for the base image
    nixpkgs_branch = "nixos-20.03";
    nixpkgs_rev = "5272327b81ed355bbed5659b8d303cf2979b6953";
  };
  kubernetesNode = {
    config, pkgs, ...
  } : {
    deployment = {
      targetEnv = "virtualbox";
      virtualbox = {
        disks.disk1.baseImage = baseImage;
        memorySize = 2048;
        vcpu = 1;
        headless = true;
      };
    };
  };
in
{
  kubernetes-master = {
    config, pkgs, ...
  } : {
    deployment = {
      targetEnv = "virtualbox";
      virtualbox = {
        disks.disk1.baseImage = baseImage;
        memorySize = 2048;
        vcpu = 2;
        headless = true;
      };
    };
  };
  kubernetes-node-1 = kubernetesNode;
}
