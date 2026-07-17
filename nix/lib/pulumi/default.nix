{ pkgs, lib }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit lib; });

  packages = {
    genSchema = callPackage ./gen-schema.nix;
    genSdk = callPackage ./gen-sdk.nix;
  };
in
packages
