{
  pkgs,
  lib,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  strings = pkgs.callPackage ../strings.nix { };
in
{
  genProviderSpec = lib.callPackageWith {
    inherit terraform-plugin-codegen-openapi;
  } ./gen-provider-spec.nix;

  genProvider = lib.callPackageWith {
    inherit terraform-plugin-codegen-framework;
  } ./gen-provider.nix;

  scaffold = lib.callPackageWith {
    inherit strings terraform-plugin-codegen-framework;
  } ./scaffold.nix;
}
