{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    genProviderTemplate = callPackage ./gen-provider-template.nix;
    genProvider = callPackage ./gen-provider.nix;
  };
in
packages
