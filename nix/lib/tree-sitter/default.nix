{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);

  packages = {
    build = callPackage ./build.nix { };
    generate = callPackage ./generate.nix { };
    init = callPackage ./init.nix { };
    parse = callPackage ./parse.nix { };
    playground = callPackage ./playground.nix { };
  };
in
packages
