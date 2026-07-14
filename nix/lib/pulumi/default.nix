{ pkgs, lib }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit lib; });
  packages = {
    convert = callPackage ./convert.nix { };
    genSdk = callPackage ./gen-sdk.nix { };
  };
in
packages
