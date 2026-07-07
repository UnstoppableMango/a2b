{ pkgs, gossamer }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith ({ inherit cli gossamer; } // packages // pkgs);

  packages = {
    build = callPackage ./build.nix;
    check = callPackage ./check.nix;
    runCommand = callPackage ./run-command.nix;
  };
in
packages
