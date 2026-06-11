{ pkgs }:
{
  buildProviderSpec =
    attrs:
    import ./plugin-codegen-openapi.nix (
      {
        lib = attrs.lib ? pkgs.lib;
        runCommand = attrs.runCommand ? pkgs.runCommand;
        terraform-plugin-codegen-openapi =
          attrs.terraform-plugin-codegen-openapi ? pkgs.terraform-plugin-codegen-openapi;
      }
      // attrs
    );
}
