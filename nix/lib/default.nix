{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
{
  strings = pkgs.callPackage ./strings.nix { };

  terraform = pkgs.callPackage ./terraform {
    inherit terraform-plugin-codegen-framework;
    inherit terraform-plugin-codegen-openapi;
  };
}
