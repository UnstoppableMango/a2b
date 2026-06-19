{ pkgs }:
let
  cli = pkgs.callPackage ../cli.nix { };
  callPackage = pkgs.lib.callPackageWith ({ inherit cli; } // packages // pkgs);

  packages = {
    build = callPackage ./build.nix;
    convert = callPackage ./convert.nix;
    generate = callPackage ./generate.nix;
    mkTemplate = callPackage ./mk-template.nix;
  };
in
packages
