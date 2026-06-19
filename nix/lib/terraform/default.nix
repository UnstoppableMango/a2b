{
  pkgs,
  lib,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
{
  genProviderSpec =
    attrs:
    import ./gen-provider-spec.nix (
      {
        inherit (pkgs) runCommand;
        inherit lib terraform-plugin-codegen-openapi;
      }
      // attrs
    );

  genProvider =
    attrs:
    import ./gen-provider.nix (
      {
        inherit (pkgs) runCommand;
        inherit lib terraform-plugin-codegen-framework;
      }
      // attrs
    );

  scaffold =
    attrs:
    import ./scaffold.nix (
      {
        inherit (pkgs) runCommand;
        inherit lib terraform-plugin-codegen-framework;
      }
      // attrs
    );
}
