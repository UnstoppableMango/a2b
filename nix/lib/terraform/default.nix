{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
{
  genProviderSpec =
    attrs:
    import ./plugin-codegen-openapi.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit terraform-plugin-codegen-openapi;
      }
      // attrs
    );

  genProvider =
    attrs:
    import ./plugin-codegen-framework.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit terraform-plugin-codegen-framework;
      }
      // attrs
    );
}
