{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  strings = pkgs.callPackage ../strings.nix { };
in
{
  genProviderSpec = pkgs.callPackageWith {
    inherit (pkgs) lib runCommand;
    inherit terraform-plugin-codegen-openapi;
  } ./gen-provider-spec.nix;

  genProvider = pkgs.callPackageWith {
    inherit (pkgs) lib runCommand;
    inherit terraform-plugin-codegen-framework;
  } ./gen-provider.nix;

  scaffold = pkgs.callPackageWith {
    inherit (pkgs) lib runCommand;
    inherit strings terraform-plugin-codegen-framework;
  } ./scaffold.nix;
}
