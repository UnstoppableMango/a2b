{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    manifestPod = callPackage ./manifest-pod.nix;
  };
in
packages
