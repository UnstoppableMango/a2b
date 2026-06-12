{ pkgs, terraform-plugin-codegen-openapi }:
{
  buildProviderSpec =
    attrs:
    import ./plugin-codegen-openapi.nix (
      {
        lib = attrs.lib or pkgs.lib;
        runCommand = attrs.runCommand or pkgs.runCommand;
        terraform-plugin-codegen-openapi =
          attrs.terraform-plugin-codegen-openapi or terraform-plugin-codegen-openapi;
      }
      // attrs
    );
}
