{
  pkgs,
  lib,
  pulumi-dotnet,
  pulumi-java,
  pulumi-yaml,
}:
let
  callPackage = pkgs.lib.callPackageWith (
    packages
    // pkgs
    // {
      inherit
        lib
        pulumi-dotnet
        pulumi-java
        pulumi-yaml
        ;
    }
  );
  packages = {
    convert = callPackage ./convert.nix { };
    genSdk = callPackage ./gen-sdk.nix { };
  };
in
packages
