{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);

  packages = {
    parse = callPackage ./parse.nix { };
  };
in
packages
