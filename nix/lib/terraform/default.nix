{ pkgs, terraform-plugin-codegen-openapi }:
{
  buildProviderSpec =
    attrs:
    import ./plugin-codegen-openapi.nix (
      {
        inherit (pkgs) lib runCommand;
        inherit terraform-plugin-codegen-openapi;
      }
      // attrs
    );
}
