{
  pkgs,
  lib,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  callPackage = pkgs.lib.callPackageWith (
    packages
    // pkgs
    // {
      inherit lib terraform-plugin-codegen-framework terraform-plugin-codegen-openapi;
    }
  );

  packages = {
    genProviderSpec = callPackage ./gen-provider-spec.nix;
    genProvider = callPackage ./gen-provider.nix;
    scaffold = callPackage ./scaffold.nix;
  };
in
packages
