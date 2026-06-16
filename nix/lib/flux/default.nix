{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    install = callPackage ./install.nix;
    createSourceGit = callPackage ./create-source-git.nix;
    createKustomization = callPackage ./create-kustomization.nix;
  };
in
packages
