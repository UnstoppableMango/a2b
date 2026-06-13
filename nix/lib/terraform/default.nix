{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  strings = pkgs.callPackage ../strings.nix { };
in
{
  genProviderSpec =
    attrs:
    import ./gen-provider-spec.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit terraform-plugin-codegen-openapi;
      }
      // attrs
    );

  genProvider =
    attrs:
    import ./gen-provider.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit terraform-plugin-codegen-framework;
      }
      // attrs
    );

  scaffold =
    attrs:
    import ./scaffold.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit strings terraform-plugin-codegen-framework;
      }
      // attrs
    );
}
