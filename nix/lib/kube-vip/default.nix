{ pkgs, kube-vip }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit kube-vip; });

  packages = {
    manifestPod = callPackage ./manifest-pod.nix { };
  };
in
packages
