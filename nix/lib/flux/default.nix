{ pkgs }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith ({ inherit cli; } // packages // pkgs);

  packages = {
    install = callPackage ./install.nix { };
    createSourceGit = callPackage ./create-source-git.nix { };
    createKustomization = callPackage ./create-kustomization.nix { };
    gotkComponents = callPackage ./gotk-components.nix { };
  };
in
packages
