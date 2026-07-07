{ pkgs, gossamer }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith ({ inherit cli gossamer; } // packages // pkgs);

  packages = {
    build = callPackage ./build.nix;
    check = callPackage ./check.nix;
  };
in
packages
