{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  inherit (pkgs.lib) callPackageWith;
  strings = pkgs.callPackage ../strings.nix { };
in
{
  genProviderSpec = callPackageWith {
    inherit terraform-plugin-codegen-openapi;
  } ./gen-provider-spec.nix;

  genProvider = callPackageWith {
    inherit terraform-plugin-codegen-framework;
  } ./gen-provider.nix;

  scaffold = callPackageWith {
    inherit strings terraform-plugin-codegen-framework;
  } ./scaffold.nix;
}
